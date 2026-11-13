import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Spaced perspective carousel with a complete reading pause after movement.
class ShoppingProductCarousel extends StatefulWidget {
  const ShoppingProductCarousel({super.key, required this.children, this.reverse = false, this.tall = false});
  final List<Widget> children;
  final bool reverse, tall;
  @override
  State<ShoppingProductCarousel> createState() => _ShoppingProductCarouselState();
}

class _ShoppingProductCarouselState extends State<ShoppingProductCarousel> {
  PageController? _pages;
  Timer? _timer;
  double _fraction = 0;
  int _page = 0;
  bool _hovered = false, _focused = false, _paused = false, _moving = false, _reduced = false;
  bool get _loop => widget.children.length >= 5;
  int get _index => _page % widget.children.length;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
    _schedule();
  }
  bool get _visible {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    final render = context.findRenderObject();
    if (render is! RenderBox || !render.hasSize) return false;
    final top = render.localToGlobal(Offset.zero).dy;
    final screen = MediaQuery.sizeOf(context).height;
    return top < screen - 100 && top + render.size.height > 150;
  }
  void _schedule() {
    _timer?.cancel();
    if (!mounted || _reduced || _paused || _hovered || _focused || widget.children.length < 2) return;
    _timer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      if (!_moving && _visible) {
        _move(widget.reverse ? -1 : 1);
      } else {
        _schedule();
      }
    });
  }
  Future<void> _move(int direction) async {
    final controller = _pages;
    if (_moving || controller == null || !controller.hasClients || widget.children.length < 2) return;
    _timer?.cancel();
    var target = _page + direction;
    if (!_loop && (target < 0 || target >= widget.children.length)) {
      target = direction > 0 ? 0 : widget.children.length - 1;
    }
    _moving = true;
    try {
      if (_reduced) {
        controller.jumpToPage(target);
      } else {
        await controller.animateToPage(target, duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic);
      }
    } finally {
      if (mounted) { _moving = false; _schedule(); }
    }
  }
  @override
  void dispose() { _timer?.cancel(); _pages?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    if (widget.children.isEmpty) return const SizedBox.shrink();
    return MouseRegion(
      onEnter: (_) { _hovered = true; _timer?.cancel(); },
      onExit: (_) { _hovered = false; _schedule(); },
      child: Focus(onFocusChange: (value) { _focused = value; _schedule(); },
        child: Column(children: [
          LayoutBuilder(builder: (context, box) {
            final mobile = box.maxWidth < 680;
            final slot = mobile ? math.min(350.0, box.maxWidth * .88) : math.min(330.0, box.maxWidth * .46);
            final fraction = slot / box.maxWidth;
            if (_pages == null || (_fraction - fraction).abs() > .001) {
              final old = _pages;
              _page = _pages == null ? (_loop ? widget.children.length * 1000 : 0) : _page;
              _fraction = fraction;
              _pages = PageController(initialPage: _page, viewportFraction: fraction);
              if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
            }
            final controller = _pages!;
            final height = widget.tall ? 580.0 : 550.0;
            return NotificationListener<ScrollNotification>(
              onNotification: (notice) {
                if (notice is ScrollStartNotification) { _moving = true; _timer?.cancel(); }
                if (notice is ScrollEndNotification) { _moving = false; _schedule(); }
                return false;
              },
              child: SizedBox(height: height, child: PageView.builder(
                controller: controller,
                itemCount: _loop ? null : widget.children.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, page) => AnimatedBuilder(animation: controller,
                  child: Padding(padding: EdgeInsets.symmetric(horizontal: mobile ? 10 : 14, vertical: 24),
                    child: widget.children[page % widget.children.length]),
                  builder: (context, child) {
                    final position = controller.hasClients && controller.position.hasContentDimensions
                      ? (controller.page ?? _page.toDouble()) : _page.toDouble();
                    final distance = (page - position).clamp(-3.0, 3.0).toDouble();
                    final scale = (1 - distance.abs() * .075).clamp(.80, 1.0).toDouble();
                    return Transform(alignment: Alignment.center,
                      transform: Matrix4.identity()..setEntry(3, 2, .0006)..rotateY(-distance.clamp(-2.0, 2.0) * .12),
                      child: Transform.scale(scale: scale,
                        child: IgnorePointer(ignoring: distance.abs() > .55,
                          child: ExcludeSemantics(excluding: distance.abs() > .55, child: child))),
                    );
                  }),
              )),
            );
          }),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(tooltip: SolarLanguage.instance.translate('Previous product'), onPressed: () => _move(-1), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8),
            SolarText('${_index + 1} / ${widget.children.length}'),
            const SizedBox(width: 8),
            IconButton(tooltip: SolarLanguage.instance.translate('Next product'), onPressed: () => _move(1), icon: const Icon(Icons.arrow_forward_rounded)),
            if (!_reduced) IconButton(tooltip: SolarLanguage.instance.translate(_paused ? 'Play slideshow' : 'Pause slideshow'),
              onPressed: () { setState(() => _paused = !_paused); _schedule(); },
              icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded)),
          ]),
        ])),
    );
  }
}
