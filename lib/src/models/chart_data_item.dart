/// Abstract class for data item.
abstract class ChartDataItem {
  ChartDataItem({this.key});

  String? key;

  /// Dispose all animations.
  void dispose();
}
