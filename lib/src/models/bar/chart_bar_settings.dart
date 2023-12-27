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

  ///背景颜色
  final Color? barBackground;

  ///瀑布图瀑布走向
  final WaterfallBarDirection? waterfallBarDirection;

  /// 频率需与ChartAxisSettingsAxis的frequency一致 用于计算
  final double frequency;

  const ChartBarSettings({
    this.thickness = 4.0,
    this.radius = BorderRadius.zero,
    this.barBackground,
    this.waterfallBarDirection,
    this.frequency = 1.0,
  });
}
