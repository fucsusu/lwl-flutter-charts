part of '../chart_axis_layer.dart';

/// A collection of values for settings in axises.
class ChartAxisSettings {
  /// X轴是否居中显示
  final bool centerX;

  /// 是否是瀑布模式
  final bool waterfallMode;

  /// The x of the axis.
  final ChartAxisSettingsAxis x;

  /// The y of the axis.
  final ChartAxisSettingsAxis y;

  const ChartAxisSettings({
    required this.x,
    required this.y,
    this.centerX = false,
    this.waterfallMode = false,
  });
}
