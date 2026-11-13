import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'seed.dart';
import 'source_registry.dart';

final solarNavigatorKey = GlobalKey<NavigatorState>();

class SolarLanguageScope extends InheritedNotifier<SolarLanguage> {
  SolarLanguageScope({super.key, required super.child}) : super(notifier: SolarLanguage.instance);
}

class _Phrase {
  const _Phrase(this.key, this.values);
  final String key;
  final List<String> values;
}

/// Presentation only. Canonical API values and editable form contents stay intact.
class SolarLanguage extends ChangeNotifier {
  SolarLanguage._();
  static final instance = SolarLanguage._();
  static const names = {'en':'English','ha':'Hausa','yo':'Yorùbá','ig':'Igbo','pcm':'Nigerian Pidgin'};
  static final _spaces = RegExp(r'\s+');
  String code = 'en';
  final Map<String, Map<String,String>> _cache = {};
  final Map<String, Set<String>> _queue = {};
  final Map<String, Set<String>> _failed = {};
  final Set<String> _publicText = {};
  final List<(String,RegExp)> _patterns = [for(final key in solarTemplates) (key, _templatePattern(key))];
  Timer? _timer;
  bool _sending = false;
  int pendingCount = 0;
  bool unavailable = false;
  bool get hasIssues => unavailable || (_failed[code]?.isNotEmpty ?? false);
  static String normalise(String value) => value.replaceAll(_spaces,' ').trim();
  static void watch(BuildContext context) { context.dependOnInheritedWidgetOfExactType<SolarLanguageScope>(); }
  static FormFieldValidator<T>? validation<T>(FormFieldValidator<T>? original) => original == null ? null : (value) {
    final result = original(value);
    return result == null ? null : instance.translate(result);
  };
  static RegExp _templatePattern(String key) {
    final matches = RegExp(r'__SID_\d+__').allMatches(key);
    final b = StringBuffer('^'); var offset = 0;
    for(final match in matches) {
      b.write(RegExp.escape(key.substring(offset,match.start)));
      b.write('(.*?)'); offset=match.end;
    }
    b.write(RegExp.escape(key.substring(offset)));b.write(r'$');
    return RegExp(b.toString());
  }
  _Phrase? _resolve(String value) {
    final key=normalise(value);
    if(solarSourceKeys.contains(key) || solarSeed.containsKey(key) || _publicText.contains(key)) return _Phrase(key, const []);
    for(final entry in _patterns) {
      final match=entry.$2.firstMatch(key);
      if(match != null) return _Phrase(entry.$1,[for(var i=1;i<=match.groupCount;i++) match.group(i) ?? '']);
    }
    return null; // Unknown identifiers and personal data are never sent to the model.
  }
  /// Call only for descriptions/categories/names already returned by the public catalogue.
  void registerPublicText(Iterable<String> values) {
    for(final value in values) {
      final key=normalise(value);
      if(key.isNotEmpty && key.length<=6000) _publicText.add(key);
    }
  }
  Future<void> restore() async {
    try {
      final prefs=await SharedPreferences.getInstance();
      final saved=prefs.getString('solarid_language');
      if(names.containsKey(saved)) code=saved!;
      for(final language in names.keys.where((v)=>v!='en')) {
        final stored=prefs.getString('solarid_translation_v2_$language');
        if(stored!=null) {
          final values=jsonDecode(stored);
          if(values is Map) _cache[language]={for(final e in values.entries) if(e.key is String && e.value is String) e.key as String:e.value as String};
        }
      }
    } catch(_) { /* English remains available if local storage cannot be read. */ }
  }
  Future<void> select(String language) async {
    if(!names.containsKey(language)) return;
    code=language; unavailable=false; _failed.remove(language);_timer?.cancel();
    notifyListeners();
    if((_queue[language]?.isNotEmpty ?? false)) _schedule();
    try { final p=await SharedPreferences.getInstance();await p.setString('solarid_language',language); } catch(_) {}
  }
  String translate(String value, {bool enabled=true}) {
    if(!enabled || code=='en' || value.trim().isEmpty || value=='SolarID' || value=='Paystack') return value;
    var resolved=_resolve(value);
    if(resolved==null) {
      final key=normalise(value);
      for(final entry in solarSeed.entries) {
        if(entry.value.values.any((v)=>normalise(v)==key)) { resolved=_Phrase(entry.key,const []);break; }
      }
      if(resolved==null) {
        for(final values in _cache.values) {
          for(final entry in values.entries) {
            if(normalise(entry.value)==key) { resolved=_Phrase(entry.key,const []);break; }
          }
          if(resolved!=null)break;
        }
      }
    }
    if(resolved==null) return value;
    final found=solarSeed[resolved.key]?[code] ?? _cache[code]?[resolved.key];
    if(found!=null) {
      var result=found;
      for(var i=0;i<resolved.values.length;i++) result=result.replaceAll('__SID_${i}__',resolved.values[i]);
      return result;
    }
    if(!(_failed[code]?.contains(resolved.key) ?? false)) {
      (_queue[code] ??= {}).add(resolved.key);
      _schedule();
    }
    return '…'; // Never present untranslated English as a completed translation.
  }
  void retry() {
    _failed.remove(code);unavailable=false;notifyListeners();_schedule();
  }
  void _schedule() {
    if(code=='en' || _timer?.isActive==true || _sending) return;
    _timer=Timer(const Duration(milliseconds:350), _flush);
  }
  Future<void> _flush() async {
    if(_sending || code=='en')return;
    final language=code;
    final texts=(_queue[language] ?? <String>{}).take(12).toList();
    if(texts.isEmpty)return;
    _sending=true;pendingCount=texts.length;notifyListeners();
    try {
      final response=await http.post(Uri.parse('${ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'),'')}/i18n/batch'),
        headers:{'Content-Type':'application/json'},
        body:jsonEncode({'language':language,'texts':texts}),
      ).timeout(const Duration(seconds:20));
      if(response.statusCode!=200)throw StateError('Translation service unavailable');
      final data=jsonDecode(response.body) as Map<String,dynamic>;
      final values=Map<String,dynamic>.from(data['translations'] as Map? ?? {});
      for(final entry in values.entries) {
        if(entry.value is String) {
          (_cache[language] ??= {})[entry.key]=entry.value as String;
          _queue[language]?.remove(entry.key);
        }
      }
      for(final key in [...(data['failed'] as List? ?? []),...(data['rejected'] as List? ?? [])]) {
        if(key is String) { (_failed[language] ??= {}).add(key);_queue[language]?.remove(key); }
      }
      unavailable=false;
      if(values.isNotEmpty) {
        try {
          final p=await SharedPreferences.getInstance();
          // Persist static display text only, not seller content or personal values.
          await p.setString('solarid_translation_v2_$language',jsonEncode({for(final e in (_cache[language] ?? <String,String>{}).entries) if(solarSourceKeys.contains(e.key)) e.key:e.value}));
        } catch(_) {}
      }
    } catch(_) { unavailable=true; }
    finally {
      _sending=false;pendingCount=(_queue[code]?.length ?? 0);notifyListeners();
      if(!unavailable && pendingCount>0 && code!='en') _timer=Timer(const Duration(seconds:2),_flush);
    }
  }
}

class SolarText extends Text {
  const SolarText(super.data, {super.key,super.style,super.strutStyle,super.textAlign,
    super.textDirection,super.locale,super.softWrap,super.overflow,super.textScaleFactor,
    super.textScaler,super.maxLines,super.semanticsLabel,super.textWidthBasis,
    super.textHeightBehavior,super.selectionColor,this.translate=true});
  final bool translate;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation:SolarLanguage.instance,builder:(context,_)=>Text(
    SolarLanguage.instance.translate(data ?? '',enabled:translate),style:style,strutStyle:strutStyle,
    textAlign:textAlign,textDirection:textDirection,locale:locale,softWrap:softWrap,
    overflow:overflow,textScaleFactor:textScaleFactor,textScaler:textScaler,maxLines:maxLines,
    semanticsLabel:semanticsLabel==null?null:SolarLanguage.instance.translate(semanticsLabel!),
    textWidthBasis:textWidthBasis,textHeightBehavior:textHeightBehavior,selectionColor:selectionColor,
  ));
}

/// Getters preserve const InputDecoration call sites and translate display labels only.
class SolarInputDecoration extends InputDecoration {
  const SolarInputDecoration({super.icon,super.iconColor,super.label,super.labelText,
    super.labelStyle,super.floatingLabelStyle,super.helper,super.helperText,super.helperStyle,
    super.helperMaxLines,super.hintText,super.hintStyle,super.hintTextDirection,super.hintMaxLines,
    super.hintFadeDuration,super.error,super.errorText,super.errorStyle,super.errorMaxLines,
    super.floatingLabelBehavior,super.floatingLabelAlignment,super.isCollapsed,super.isDense,
    super.contentPadding,super.prefixIcon,super.prefixIconConstraints,super.prefix,
    super.prefixText,super.prefixStyle,super.prefixIconColor,super.suffixIcon,
    super.suffix,super.suffixText,super.suffixStyle,super.suffixIconColor,super.suffixIconConstraints,
    super.counter,super.counterText,super.counterStyle,super.filled,super.fillColor,
    super.focusColor,super.hoverColor,super.errorBorder,super.focusedBorder,
    super.focusedErrorBorder,super.disabledBorder,super.enabledBorder,super.border,
    super.enabled,super.semanticCounterText,super.alignLabelWithHint,super.constraints});
  @override String? get labelText=>super.labelText==null?null:SolarLanguage.instance.translate(super.labelText!);
  @override String? get hintText=>super.hintText==null?null:SolarLanguage.instance.translate(super.hintText!);
  @override String? get helperText=>super.helperText==null?null:SolarLanguage.instance.translate(super.helperText!);
  @override String? get errorText=>super.errorText==null?null:SolarLanguage.instance.translate(super.errorText!);
  @override String? get prefixText=>super.prefixText==null?null:SolarLanguage.instance.translate(super.prefixText!);
  @override String? get suffixText=>super.suffixText==null?null:SolarLanguage.instance.translate(super.suffixText!);
  @override String? get counterText=>super.counterText==null?null:SolarLanguage.instance.translate(super.counterText!);
}

class SolarTextSpan extends TextSpan {
  const SolarTextSpan({super.text,super.children,super.style,super.recognizer,
    super.mouseCursor,super.onEnter,super.onExit,super.semanticsLabel,super.locale,super.spellOut});
  @override String? get text=>super.text==null?null:SolarLanguage.instance.translate(super.text!);
}

class LanguageFrame extends StatelessWidget {
  const LanguageFrame({super.key,required this.child});
  final Widget child;
  @override Widget build(BuildContext context)=>AnimatedBuilder(
    animation:SolarLanguage.instance,
    builder:(context,_) {
      final language=SolarLanguage.instance;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
        Material(color:const Color(0xFF102F46),child:SafeArea(bottom:false,child:Padding(
          padding:const EdgeInsets.symmetric(horizontal:30,vertical:3),
          child:Wrap(alignment:WrapAlignment.end,crossAxisAlignment:WrapCrossAlignment.center,spacing:10,runSpacing:4,children:[
            if(language.code!='en' && (language.pendingCount>0 || language.hasIssues))
              Text(language.translate(language.hasIssues?'Translation unavailable. Retry or choose English.':'Preparing translations…'),style:const TextStyle(color:Colors.white,fontSize:12)),
            if(language.code!='en' && language.hasIssues)
              TextButton(onPressed:language.retry,child:Text(language.translate('Retry'),style:const TextStyle(color:Colors.white))),
            TextButton.icon(
              onPressed:() async {
                final overlay=solarNavigatorKey.currentState?.overlay;
                if(overlay==null)return;
                final selected=await showDialog<String>(context:overlay.context,builder:(ctx)=>SimpleDialog(
                  title:Text(language.translate('Choose your language')),
                  children:[for(final entry in SolarLanguage.names.entries) SimpleDialogOption(
                    onPressed:()=>Navigator.pop(ctx,entry.key),
                    child:Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(entry.value)),
                  )],
                ));
                if(selected!=null)await language.select(selected);
              },
              icon:const Icon(Icons.language,color:Colors.white,size:20),
              label:Row(mainAxisSize:MainAxisSize.min,children:[Text(SolarLanguage.names[language.code]!,style:const TextStyle(color:Colors.white)),const Icon(Icons.arrow_drop_down,color:Colors.white)]),
            ),
          ]),
        ))),
        Expanded(child:child),
      ]);
    },
  );
}
