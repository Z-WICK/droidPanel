import 'dart:async';

import 'package:flutter/material.dart';

/// A lightweight one-shot reveal animation for section-level content.
class EntranceTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;
  final bool enabled;

  const EntranceTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0, 0.035),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  @override
  State<EntranceTransition> createState() => _EntranceTransitionState();
}

class _EntranceTransitionState extends State<EntranceTransition> {
  Timer? _timer;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = !widget.enabled;
    if (widget.enabled) {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() => _visible = true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant EntranceTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _timer?.cancel();
      _visible = !widget.enabled;
      if (widget.enabled) {
        _timer = Timer(widget.delay, () {
          if (mounted) {
            setState(() => _visible = true);
          }
        });
      } else {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.enabled || disableAnimations) {
      return widget.child;
    }

    return AnimatedSlide(
      offset: _visible ? Offset.zero : widget.beginOffset,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
