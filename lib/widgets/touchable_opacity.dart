import 'package:flutter/material.dart';

class TouchableOpacity extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double activeOpacity;
  final Duration duration;
  final HitTestBehavior behavior;

  const TouchableOpacity({
    super.key,
    required this.child,
    this.onTap,
    this.activeOpacity = 0.6,
    this.duration = const Duration(milliseconds: 100),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<TouchableOpacity> createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) => setState(() => _isDown = false),
      onTapCancel: () => setState(() => _isDown = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: widget.duration,
        opacity: _isDown ? widget.activeOpacity : 1.0,
        child: widget.child,
      ),
    );
  }
}
