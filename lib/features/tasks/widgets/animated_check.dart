import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors.dart';

class AnimatedCheck extends StatelessWidget {
  final bool checked;
  final Color color;
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
        : AppColors.border.withAlpha((0.90 * 255).toInt());

    final fillColor = checked
        ? color.withAlpha((0.22 * 255).toInt())
        : Colors.white.withAlpha((0.04 * 255).toInt());

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        // This animates 0 -> 1 when checked, and 1 -> 0 when unchecked
        tween: Tween<double>(begin: 0, end: checked ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          // Pop effect: scale slightly above 1 at the beginning then settle to 1
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
                          color: Colors.black.withAlpha((0.28 * 255).toInt()),
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
                    // looks bold + crisp
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

    // A nice check path relative to size
    // Start: (0.15w, 0.55h) -> mid: (0.42w, 0.78h) -> end: (0.85w, 0.25h)
    final start = Offset(size.width * 0.15, size.height * 0.55);
    final mid = Offset(size.width * 0.42, size.height * 0.78);
    final end = Offset(size.width * 0.85, size.height * 0.25);

    // Two segments: start->mid and mid->end
    final firstLen = (mid - start).distance;
    final secondLen = (end - mid).distance;
    final totalLen = firstLen + secondLen;

    // How much of the total length we should draw
    final drawLen = totalLen * progress;

    final path = Path();

    if (drawLen <= firstLen) {
      // draw only part of first segment
      final t1 = drawLen / firstLen;
      final cur = Offset.lerp(start, mid, t1)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(cur.dx, cur.dy);
    } else {
      // draw full first segment + part of second
      path.moveTo(start.dx, start.dy);
      path.lineTo(mid.dx, mid.dy);

      final remaining = drawLen - firstLen;
      final t2 = (remaining / secondLen).clamp(0.0, 1.0);
      final cur = Offset.lerp(mid, end, t2)!;
      path.lineTo(cur.dx, cur.dy);
    }

    // Optional: a tiny fade-in near start looks smoother
    // (Keep it simple: we just draw)
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _CheckStrokePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
