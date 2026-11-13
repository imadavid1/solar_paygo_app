import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import '../marketplace/professional_directory.dart';

typedef ProfessionalPanelBuilder = Widget Function(BuildContext context, SampleProfessional profile, Future<void> Function(Future<void> Function()) pauseForAction);

/// A wide photo carousel. Repeated pages preserve the six unique profile identities.
class ProfessionalLoopStrip extends StatefulWidget {
  const ProfessionalLoopStrip({super.key, required this.profiles, required this.panelBuilder});
  final List<SampleProfessional> profiles;
  final ProfessionalPanelBuilder panelBuilder;

  @override
  State<ProfessionalLoopStrip> createState() => _ProfessionalLoopStripState();
}

class _ProfessionalLoopStripState extends State<ProfessionalLoopStrip> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 6000;
  bool _hovered = false;
  bool _focused = false;
  bool _dragging = false;
  bool _manualPause = false;
  bool _reducedMotion = false;
  bool _routeActive = true;
  bool _moving = false;
  bool _dialogOpen = false;

  bool get _paused => _hovered || _focused || _dragging || _dialogOpen || _manualPause || _reducedMotion || !_routeActive;

  @override
  void initState() {
    super.initState();
    // A large offset allows immediate backwards navigation as well as forwards looping.
    _page = widget.profiles.length * 1000;
    _controller = PageController(initialPage: _page, viewportFraction: .82);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _routeActive = TickerMode.of(context);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_paused || widget.profiles.length < 2) return;
    _timer = Timer.periodic(const Duration(milliseconds: 4600), (_) => _move(1));
  }

  void _setPause({bool? hovered, bool? focused, bool? dragging, bool? manual}) {
    setState(() {
      if (hovered != null) _hovered = hovered;
      if (focused != null) _focused = focused;
      if (dragging != null) _dragging = dragging;
      if (manual != null) _manualPause = manual;
    });
    _restartTimer();
  }

  Future<void> _move(int direction) async {
    if (!_controller.hasClients || _moving || widget.profiles.isEmpty) return;
    _moving = true;
    final next = _page + direction;
    try {
      if (_reducedMotion) {
        _controller.jumpToPage(next);
      } else {
        await _controller.animateToPage(next, duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
      }
    } finally {
      _moving = false;
    }
  }

  Future<void> _pauseForAction(Future<void> Function() action) async {
    setState(() => _dialogOpen = true);
    _restartTimer();
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _dialogOpen = false);
        _restartTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    if (widget.profiles.isEmpty) return const SizedBox.shrink();
    final current = _page % widget.profiles.length;
    return Focus(
      onFocusChange: (value) => _setPause(focused: value),
      child: MouseRegion(
        onEnter: (_) => _setPause(hovered: true),
        onExit: (_) => _setPause(hovered: false),
        child: Column(children: [
          LayoutBuilder(builder: (context, constraints) {
            final baseHeight = constraints.maxWidth >= 850 ? 480.0 : 510.0;
            final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final height = baseHeight + (textScale > 1 ? (textScale - 1) * 250 : 0);
            return SizedBox(height: height, child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification && notification.dragDetails != null) _setPause(dragging: true);
                if (notification is ScrollEndNotification && _dragging) _setPause(dragging: false);
                return false;
              },
              child: Stack(children: [
              PageView.builder(
                key: const ValueKey('professional-photo-loop'),
                controller: _controller,
                allowImplicitScrolling: true,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, page) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedScale(
                    scale: page == _page ? 1 : .96,
                    duration: _reducedMotion ? Duration.zero : const Duration(milliseconds: 400),
                    child: widget.panelBuilder(context, widget.profiles[page % widget.profiles.length], _pauseForAction),
                  ),
                ),
              ),
              Positioned(left: constraints.maxWidth * .09 + 14, top: 0, bottom: 0,
                child: Center(child: IconButton.filledTonal(
                  tooltip: SolarLanguage.instance.translate('Previous professional'),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .90), foregroundColor: const Color(0xFF147FA8)),
                  onPressed: () => _move(-1), icon: const Icon(Icons.arrow_back_rounded),
                )),
              ),
              Positioned(right: constraints.maxWidth * .09 + 14, top: 0, bottom: 0,
                child: Center(child: IconButton.filledTonal(
                  tooltip: SolarLanguage.instance.translate('Next professional'),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .90), foregroundColor: const Color(0xFF147FA8)),
                  onPressed: () => _move(1), icon: const Icon(Icons.arrow_forward_rounded),
                )),
              ),
              ]),
            ));
          }),
          const SizedBox(height: 22),
          Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 10, children: [
            SolarText('${current + 1} / ${widget.profiles.length}', style: const TextStyle(color: Color(0xFF163747), fontWeight: FontWeight.w700)),
            TextButton.icon(
              onPressed: _reducedMotion ? null : () => _setPause(manual: !_manualPause),
              icon: Icon(_manualPause || _reducedMotion ? Icons.play_arrow_rounded : Icons.pause_rounded),
              label: SolarText(_reducedMotion ? 'Motion reduced' : _manualPause ? 'Play slides' : 'Pause slides'),
            ),
          ]),
        ]),
      ),
    );
  }
}
