import '../../../mrx_charts.dart';

/// 绘制堆叠图的图层
class ChartLineStackLayer extends ChartLayer {
  final List<ChartLineLayer> items;

  final bool useArea;

  ChartLineStackLayer(this.items, {this.useArea = false}) {
    if (items.isNotEmpty) {
      List addNum = List.generate(items.first.items.length, (index) => 0);
      for (var lineLayer in items) {
        lineLayer.settings.useArea = useArea;
        for (int i = 0; i < lineLayer.items.length; i++) {
          lineLayer.items[i].value += addNum[i];
          addNum[i] = lineLayer.items[i].value;
        }
      }
    }
  }

  /// Disposing all animations.
  @override
  void dispose() {
    for (var element in items) {
      for (final ChartLineDataItem item in element.items) {
        item.dispose();
      }
    }
  }
}
