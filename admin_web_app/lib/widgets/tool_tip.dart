import 'package:flutter/material.dart';

class HoverTextOverlay extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double maxWidth;

  const HoverTextOverlay({
    super.key,
    required this.text,
    this.style,
    this.maxWidth = 300,
  });

  @override
  State<HoverTextOverlay> createState() => _HoverTextOverlayState();
}

class _HoverTextOverlayState extends State<HoverTextOverlay> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: widget.maxWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 20),
          child: Material(
            elevation: 6,
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _removeOverlay(),
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
