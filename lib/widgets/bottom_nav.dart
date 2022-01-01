import 'dart:math';
import 'package:flutter/material.dart';

typedef LetIndexChange = bool Function(int);

class BottomNavBar extends StatefulWidget {
  final List<Widget> items;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int>? onTap;
  final LetIndexChange letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;
  final double? maxWidth;

  const BottomNavBar({
    super.key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    this.letIndexChange = _defaultLetIndex,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.height = 75.0,
    this.maxWidth,
  }) : assert(items.length > 0, "items must not be empty"),
       assert(index >= 0 && index < items.length);

  static bool _defaultLetIndex(int _) => true;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late double _pos;
  late int _endingIndex;
  late AnimationController _controller;
  late int _length;

  @override
  void initState() {
    super.initState();
    _length = widget.items.length;
    _pos = widget.index / _length;
    _endingIndex = widget.index;

    _controller = AnimationController(vsync: this, value: _pos);
    _controller.addListener(() {
      setState(() => _pos = _controller.value);
    });
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPos = widget.index / _length;
      _endingIndex = widget.index;
      _controller.animateTo(
        newPos,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (!widget.letIndexChange(index) || _controller.isAnimating) return;
    widget.onTap?.call(index);

    final newPos = index / _length;
    setState(() {
      _endingIndex = index;
      _controller.animateTo(
        newPos,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textDir = Directionality.of(context);

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = min(
            constraints.maxWidth,
            widget.maxWidth ?? constraints.maxWidth,
          );

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // background curve
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: _NavPainter(_pos, _length, widget.color, textDir),
                  child: SizedBox(height: widget.height),
                ),
              ),
              // floating circle button with selected tab icon
              Positioned(
                bottom: widget.height - 36,
                left: textDir == TextDirection.ltr ? _pos * maxWidth : null,
                right: textDir == TextDirection.rtl ? _pos * maxWidth : null,
                width: maxWidth / _length,
                child: Center(
                  child: AnimatedScale(
                    scale: 1.2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.buttonBackgroundColor ?? widget.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: IconTheme(
                          data: const IconThemeData(
                            size: 28,
                            color: Colors.white,
                          ),
                          child: widget.items[_endingIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // bottom nav items row
              Positioned.fill(
                child: Row(
                  children: List.generate(_length, (i) {
                    final isSelected = i == _endingIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _onTap(i),
                        child: Center(
                          child: IconTheme(
                            data: IconThemeData(
                              size: 24,
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white,
                            ),
                            child: widget.items[i],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Painter for curved background
class _NavPainter extends CustomPainter {
  final double pos;
  final int length;
  final Color color;
  final TextDirection dir;

  _NavPainter(this.pos, this.length, this.color, this.dir);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final span = 1.0 / length;
    const s = 0.2;
    final l = dir == TextDirection.rtl
        ? 0.8 - (pos + (span - s) / 2)
        : pos + (span - s) / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((l - 0.1) * size.width, 0)
      ..cubicTo(
        (l + s * 0.20) * size.width,
        size.height * 0.05,
        l * size.width,
        size.height * 0.60,
        (l + s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (l + s) * size.width,
        size.height * 0.60,
        (l + s - s * 0.20) * size.width,
        size.height * 0.05,
        (l + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavPainter old) => old.pos != pos || old.color != color;
}
