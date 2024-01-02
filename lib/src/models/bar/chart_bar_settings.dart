part of 'chart_bar_layer.dart';

enum WaterfallBarDirection {
  toLeft,
  toRight,
}

/// A collection of values for settings in bars.
class ChartBarSettings {
  /// The radius of bars.
  ///
  /// Defaults to 4.0
  final BorderRadius radius;

  /// The thickness of bars.
  ///
  /// Defaults to BorderRadius.zero
  final double thickness;

  ///点击范围 默认取值thickness
  final double? touchThickness;

  ///背景颜色
  final Color? barBackground;

  ///瀑布图瀑布走向
  final WaterfallBarDirection? waterfallBarDirection;

  const ChartBarSettings({
    this.thickness = 4.0,
    this.touchThickness,
    this.radius = BorderRadius.zero,
    this.barBackground,
    this.waterfallBarDirection,
  });
}
