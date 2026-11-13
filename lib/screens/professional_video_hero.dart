import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProfessionalVideoHero extends StatefulWidget {
  const ProfessionalVideoHero({super.key});
  @override
  State<ProfessionalVideoHero> createState() => _ProfessionalVideoHeroState();
}

class _ProfessionalVideoHeroState extends State<ProfessionalVideoHero> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _playing = false;
  bool _failed = false;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/catalogue/professionals/workers_hero.mp4');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.setLooping(true);
      if (!mounted) return;
      setState(() => _ready = true);
      if (_reduceMotion != true) await _setPlaying(true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context);
    if (_reduceMotion != reduceMotion) {
      _reduceMotion = reduceMotion;
      if (_ready) _setPlaying(!reduceMotion);
    }
  }

  Future<void> _setPlaying(bool play) async {
    try {
      if (play) { await _controller.play(); } else { await _controller.pause(); }
      if (mounted) setState(() => _playing = play && _controller.value.isPlaying);
    } catch (_) {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, box) {
    final wide = box.maxWidth >= 850;
    return Stack(children: [
      Positioned.fill(child: Image.asset(
        'assets/images/catalogue/professionals/workers_poster.jpg',
        fit: BoxFit.cover,
        semanticLabel: 'Skilled professionals at work',
      )),
      if (_ready && !_failed)
        Positioned.fill(child: IgnorePointer(child: ClipRect(child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height,
            child: VideoPlayer(_controller)),
        )))),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [const Color(0xE610334B), const Color(0x70106388), const Color(0x251887BC)]),
      ))),
      Padding(
        padding: EdgeInsets.fromLTRB(24, wide ? 94 : 68, 24, wide ? 114 : 94),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280),
          child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SolarText('', style: TextStyle(color: Color(0xFFBFEFFF), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
            const SizedBox(height: 16),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850),
              child: SolarText('Find a trusted professional', style: TextStyle(color: Colors.white, fontSize: wide ? 58 : 38, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -1.3))),
            const SizedBox(height: 20),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 730),
              child: const SolarText('Choose a trade and Nigerian location, or type directly into the search box. Compare qualified profiles and contact the professional who fits your job.',
                style: TextStyle(color: Colors.white, fontSize: 18, height: 1.55))),
          ])),
        )),
      ),
      if (_ready && !_failed)
        Positioned(right: 22, bottom: 18, child: IconButton.filledTonal(
          tooltip: SolarLanguage.instance.translate(_playing ? 'Pause background video' : 'Play background video'),
          onPressed: () => _setPlaying(!_playing),
          icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        )),
    ]);
  }); }
}
