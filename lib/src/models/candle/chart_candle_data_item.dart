part of 'chart_candle_layer.dart';

/// A collection of values for a candle in a chart.
class ChartCandleDataItem {
  /// The color of candle item.
  final Color color;

  /// The value1 of candle item.
  final ChartCandleDataItemValue value1;

  /// The value2 of candle item.
  final ChartCandleDataItemValue value2;

  /// The x axis of candle item.
  final double x;

  const ChartCandleDataItem({
    required this.color,
    required this.value1,
    required this.value2,
    required this.x,
  });

  /// Disposing all animations.
  void dispose() {
    value1.dispose();
    value2.dispose();
  }
}
