import 'package:flutter/material.dart';

class R {
  R(this.context);

  final BuildContext context;

  Size get size => MediaQuery.sizeOf(context);
  double get w => size.width;
  double get h => size.height;
  double get shortest => size.shortestSide;

  /// Scale factor بسيط للـ spacing/fonts بدون ما يبوّظ UI
  double get s {
    // 360 baseline
    final f = w / 360.0;
    return f.clamp(0.92, 1.18);
  }

  double sp(double v) => v * s; // spacing
  double fs(double v) => v * s; // font-size (خفيف)

  EdgeInsets pad(double all) => EdgeInsets.all(sp(all));
  EdgeInsets sym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: sp(h), vertical: sp(v));
}
