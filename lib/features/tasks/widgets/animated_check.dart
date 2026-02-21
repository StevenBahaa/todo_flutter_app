import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/theme_x.dart';

class AnimatedCheck extends StatelessWidget {
  final bool checked;
  final Color color; // priority color
  final VoidCallback? onTap;

  const AnimatedCheck({
    super.key,
    required this.checked,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = checked
        ? color
        : context.border.withAlpha((0.90 * 255).toInt());

    // ✅ بدل Colors.white: خليها من surface/background حسب الثيم
    final fillColor = checked
        ? color.withAlpha((0.22 * 255).toInt())
        : context.scheme.surfaceContainerHighest.withAlpha(
            (0.35 * 255).toInt(),
          );

    // ✅ Shadow theme-safe
    final uncheckedShadowColor = Theme.of(
      context,
    ).shadowColor.withAlpha((0.22 * 255).toInt());

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: checked ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final pop = checked ? (1.0 + 0.08 * math.sin(t * math.pi)) : 1.0;

          return Transform.scale(
            scale: pop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: checked ? 2.8 : 2.4,
                ),
                boxShadow: checked
                    ? [
                        BoxShadow(
                          color: color.withAlpha((0.35 * 255).toInt()),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: uncheckedShadowColor,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(18, 18),
                  painter: _CheckStrokePainter(
                    progress: t,
                    color: color,
                    strokeWidth: 2.8,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckStrokePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final double strokeWidth;

  _CheckStrokePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final start = Offset(size.width * 0.15, size.height * 0.55);
    final mid = Offset(size.width * 0.42, size.height * 0.78);
    final end = Offset(size.width * 0.85, size.height * 0.25);

    final firstLen = (mid - start).distance;
    final secondLen = (end - mid).distance;
    final totalLen = firstLen + secondLen;

    final drawLen = totalLen * progress;

    final path = Path();

    if (drawLen <= firstLen) {
      final t1 = drawLen / firstLen;
      final cur = Offset.lerp(start, mid, t1)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(cur.dx, cur.dy);
    } else {
      path.moveTo(start.dx, start.dy);
      path.lineTo(mid.dx, mid.dy);

      final remaining = drawLen - firstLen;
      final t2 = (remaining / secondLen).clamp(0.0, 1.0);
      final cur = Offset.lerp(mid, end, t2)!;
      path.lineTo(cur.dx, cur.dy);
    }

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _CheckStrokePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
