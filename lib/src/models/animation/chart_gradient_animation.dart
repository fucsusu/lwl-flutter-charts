import 'package:flutter/material.dart';

import '../../../mrx_charts.dart';
import 'gradient_tween.dart';

/// 提供渐变色的动画值
class ChartGradientAnimation implements ChartAnimation {
  Animation<Gradient?>? _animation;
  Gradient? _lastGradient;

  ChartGradientAnimation();

  Gradient? get current => _lastGradient = _animation?.value;

  Gradient? get last => _lastGradient;

  @override
  void dispose() {
    _animation = null;
  }

  void setup({
    required Gradient? gradient,
    required AnimationController controller,
    Curve curve = Curves.easeInOut,
    Gradient? initialGradient,
    ChartGradientAnimation? oldAnimation,
  }) {
    final Animation<Gradient?> animation = GradientTween(
      begin: oldAnimation?._lastGradient ?? initialGradient,
      end: gradient,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
    _animation = animation;
  }
}
