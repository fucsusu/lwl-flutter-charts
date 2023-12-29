import 'package:flutter/cupertino.dart';

/// 两种渐变颜色之间的插值。
class GradientTween extends Tween<Gradient?> {
  GradientTween({begin, end}) : super(begin: begin, end: end);

  @override
  Gradient? lerp(double t) => Gradient.lerp(begin, end, t);
}
