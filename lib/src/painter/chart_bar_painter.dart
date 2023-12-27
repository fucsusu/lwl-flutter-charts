part of 'chart_painter.dart';

/// Layer painter for bar.
class _ChartBarPainter {
  const _ChartBarPainter._();

  /// Draw bar.
  static void draw({
    required Canvas canvas,
    required AnimationController controller,
    required ChartBarLayer layer,
    required ChartPainterData painterData,
    required List<TouchableShape<ChartDataItem>> touchableShapes,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartBarLayer? oldLayer,
  }) {
    ///上移偏移量
    double _upShiftOffset = 0;
    for (int i = 0; i < layer.items.length; i++) {
      final ChartBarDataItem item = layer.items[i];
      _calculate(
        controller: controller,
        item: item,
        oldItem: (oldLayer?.items)?.getOrNull(i),
        painterData: painterData,
        settings: layer.settings,
        xValue: xValue,
        yValue: yValue,
        upShiftOffset: _upShiftOffset,
      );
      _drawBarBackground(layer, canvas, item, painterData);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          item.currentValuePos & item.currentValueSize,
          bottomLeft: layer.settings.radius.bottomLeft,
          bottomRight: layer.settings.radius.bottomRight,
          topLeft: layer.settings.radius.topLeft,
          topRight: layer.settings.radius.topRight,
        ),
        Paint()..color = item.currentValueColor,
      );

      touchableShapes.add(RectangleShape<ChartBarDataItem>(
          dataList: [item], rectOffset: item.currentTouchPos, rectSize: item.currentTouchSize));

      _upShiftOffset = _calculateBeforeTotalHeight(layer, _upShiftOffset, i);
    }
  }

  ///计算数据位置
  static void _calculate({
    required AnimationController controller,
    required ChartBarDataItem item,
    required ChartPainterData painterData,
    required ChartBarSettings settings,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    double upShiftOffset = 0,
    ChartBarDataItem? oldItem,
  }) {
    final double offsetX = painterData.size.width * (item.x - xValue.min) / (xValue.max - xValue.min);
    final Size size = Size(
      settings.thickness,
      painterData.size.height * (item.value - yValue.min) / (yValue.max - yValue.min),
    );
    final Offset pos = Offset(
      painterData.position.dx + offsetX - size.width.half,
      painterData.position.dy + painterData.size.height - size.height,
    );
    item.setupValue(
      color: item.color,
      controller: controller,
      initialColor: oldItem?.lastValueColor ?? Colors.transparent,
      initialPos: oldItem?.lastValuePos ??
          Offset(pos.dx, painterData.position.dy + painterData.size.height).translate(0, -upShiftOffset),
      initialSize: oldItem?.lastValueSize ?? Size(size.width, 0.0),
      pos: pos.translate(0, -upShiftOffset),
      size: size,
    );
    item.setupTouch(
      controller: controller,
      initialPos: oldItem?.lastValuePos ?? Offset(pos.dx, painterData.position.dy).translate(0, -upShiftOffset),
      initialSize: oldItem?.lastValueSize ?? Size(size.width, painterData.size.height),
      pos: Offset(pos.dx, painterData.position.dy).translate(0, -upShiftOffset),
      size: Size(size.width, painterData.size.height),
    );
  }

  ///绘制背景颜色
  static void _drawBarBackground(
    ChartBarLayer layer,
    Canvas canvas,
    ChartBarDataItem item,
    ChartPainterData painterData,
  ) {
    if (layer.settings.barBackground != null) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Offset(item.currentValuePos.dx, painterData.position.dy) & Size(layer.settings.thickness, painterData.size.height),
          bottomLeft: layer.settings.radius.bottomLeft,
          bottomRight: layer.settings.radius.bottomRight,
          topLeft: layer.settings.radius.topLeft,
          topRight: layer.settings.radius.topRight,
        ),
        Paint()..color = layer.settings.barBackground!,
      );
    }
  }

  ///计算瀑布图偏移量
  static double _calculateBeforeTotalHeight(ChartBarLayer layer, double beforeTotalHeight, int i) {
    if (layer.settings.waterfallBarDirection == WaterfallBarDirection.toLeft) {
      if (i == 0) {
        beforeTotalHeight = layer.items[i].currentValueSize.height;
      }
      if (i + 1 < layer.items.length) {
        final ChartBarDataItem nextItem = layer.items[i + 1];
        beforeTotalHeight -= nextItem.currentValueSize.height;
      }
    } else if (layer.settings.waterfallBarDirection == WaterfallBarDirection.toRight) {
      if (i + 1 == layer.items.length - 1) {
        beforeTotalHeight = 0;
      } else {
        beforeTotalHeight += layer.items[i].currentValueSize.height;
      }
    }
    return beforeTotalHeight;
  }
}
