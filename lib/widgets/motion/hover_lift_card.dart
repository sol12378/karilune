import 'package:flutter/material.dart';

import '../../theme/elevation.dart';
import '../../theme/motion.dart';

class HoverLiftCard extends StatefulWidget {
  const HoverLiftCard({
    super.key,
    required this.child,
    this.enabled = true,
    this.onTap,
    this.borderRadius = 12,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> {
  var _hovered = false;
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final lifted = _hovered && !_pressed;
    final scale = _pressed ? 0.98 : 1.0;

    final animated = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      transform: Matrix4.diagonal3Values(scale, scale, 1)
        ..setTranslationRaw(0, lifted ? -4.0 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: lifted ? AppElevation.cardHover : AppElevation.cardRest,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: animated,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: animated,
    );
  }
}
