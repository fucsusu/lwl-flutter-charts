part of '../chart_axis_layer.dart';

/// A collection of values for settings of the selected axis.
class ChartAxisSettingsAxis {
  /// The frequency of the value.
  final double frequency;

  /// The max of the value in the axis.
  double max;

  /// The min of the value in the axis.
  double min;

  /// The TextStyle in axis.
  final TextStyle textStyle;

  /// 轴是否显示
  final bool showAxis;

  /// 轴颜色
  final Color axisColor;

  ChartAxisSettingsAxis({
    required this.frequency,
    required this.max,
    required this.min,
    required this.textStyle,
    this.showAxis = false,
    this.axisColor = Colors.white,
  });

  /// Generate all items of axis.
  ChartAxisData generate({
    required String Function(double) label,
    bool center = false,
  }) {
    if (center) {
      max = max + frequency * 0.5;
      min = min - frequency * 0.5;
      return ChartAxisData(
        max: max,
        min: min,
        items: List.generate(
          (max - min) ~/ frequency,
          (index) => ChartAxisDataItem(
            label: label((index + 0.5) * frequency + min),
            value: (index + 0.5) * frequency + min,
          ),
        ),
      );
    } else {
      return ChartAxisData(
        max: max,
        min: min,
        items: List.generate(
          ((max - min) ~/ frequency) + 1,
          (index) => ChartAxisDataItem(
            label: label(index * frequency + min),
            value: index * frequency + min,
          ),
        ),
      );
    }
  }
}
