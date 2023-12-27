part of 'chart_painter.dart';

/// 坐标轴绘制
class _ChartAxisPainter {
  const _ChartAxisPainter._();

  /// Draw axis.
  static void draw({
    required Canvas canvas,
    required AnimationController controller,
    required ChartAxisLayer layer,
    required ChartPainterData painterDataAxisX,
    required ChartPainterData painterDataAxisY,
    required ChartPainterData sheetPainterData,
    ChartAxisLayer? oldLayer,
  }) {
    _drawX(
      canvas: canvas,
      controller: controller,
      data: layer.x,
      oldData: oldLayer?.x,
      painterData: painterDataAxisX,
      sheetPainterData: sheetPainterData,
      settings: layer.settings.x,
    );
    _drawY(
      canvas: canvas,
      controller: controller,
      data: layer.y,
      oldData: oldLayer?.y,
      painterData: painterDataAxisY,
      sheetPainterData: sheetPainterData,
      settings: layer.settings.y,
    );
  }

  static void _calculateX({
    required AnimationController controller,
    required ChartAxisDataItem item,
    required ChartPainterData painterData,
    required ChartAxisSettingsAxis settings,
    ChartAxisDataItem? oldItem,
  }) {
    final double offsetX = painterData.size.width * (item.value - settings.min) / (settings.max - settings.min);
    final Offset pos = Offset(
      painterData.position.dx + offsetX,
      painterData.position.dy,
    );
    item.setup(
      controller: controller,
      initialPos: oldItem?.lastPos ?? pos,
      pos: pos,
      initialTextStyle: oldItem?.lastTextStyle ??
          settings.textStyle.copyWith(
            color: Colors.transparent,
          ),
      textStyle: settings.textStyle,
      oldItem: oldItem,
    );
  }

  static void _calculateY({
    required AnimationController controller,
    required ChartAxisDataItem item,
    required ChartPainterData painterData,
    required ChartAxisSettingsAxis settings,
    ChartAxisDataItem? oldItem,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: item.label,
        style: settings.textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double diff = settings.max - settings.min;
    final double offsetY = painterData.size.height - painterData.size.height * (item.value - settings.min) / diff;
    final Offset pos = Offset(
      painterData.position.dx + painterData.size.width,
      painterData.position.dy + offsetY - textPainter.height.half,
    );
    item.setup(
      controller: controller,
      initialPos: oldItem?.lastPos ?? pos,
      initialTextStyle: settings.textStyle.copyWith(
        color: Colors.transparent,
      ),
      oldItem: oldItem,
      pos: pos,
      textStyle: settings.textStyle,
    );
  }

  static void _drawX({
    required Canvas canvas,
    required AnimationController controller,
    required ChartAxisData data,
    required ChartPainterData painterData,
    required ChartPainterData sheetPainterData,
    required ChartAxisSettingsAxis settings,
    ChartAxisData? oldData,
  }) {
    for (int i = 0; i < data.items.length; i++) {
      final ChartAxisDataItem item = data.items[i];
      _calculateX(
        controller: controller,
        item: item,
        oldItem: (oldData?.items)?.getOrNull(i),
        painterData: painterData,
        settings: settings,
      );
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: item.currentTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          item.currentPos.dx - textPainter.width.half,
          item.currentPos.dy,
        ),
      );
    }

    if (settings.showAxis) {
      Paint linePaint = Paint();
      linePaint.color = settings.axisColor;
      linePaint.strokeWidth = 1;
      linePaint.style = PaintingStyle.stroke;
      double bottomDy = sheetPainterData.size.height + sheetPainterData.position.dy + 1;

      // canvas.drawCircle(sheetPainterData.position, 5, linePaint);
      // canvas.drawRect(
      //     Rect.fromPoints(sheetPainterData.position,
      //         sheetPainterData.position + Offset(sheetPainterData.size.width, sheetPainterData.size.height)),
      //     linePaint);

      canvas.drawLine(Offset(sheetPainterData.position.dx, bottomDy),
          Offset(sheetPainterData.position.dx + sheetPainterData.size.width + 1, bottomDy), linePaint);

      canvas.drawDashLine(
          List.generate(data.items.length + 1, (index) {
            final double offsetX = painterData.size.width * (index * settings.frequency) / (settings.max - settings.min);
            return Offset(painterData.position.dx + offsetX, bottomDy);
          }),
          1,
          height: 5);
    }
  }

  static void _drawY({
    required Canvas canvas,
    required AnimationController controller,
    required ChartAxisData data,
    required ChartPainterData painterData,
    required ChartAxisSettingsAxis settings,
    required ChartPainterData sheetPainterData,
    ChartAxisData? oldData,
  }) {
    for (int i = 0; i < data.items.length; i++) {
      final ChartAxisDataItem item = data.items[i];
      _calculateY(
        controller: controller,
        item: item,
        oldItem: (oldData?.items)?.getOrNull(i),
        painterData: painterData,
        settings: settings,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: item.currentTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          item.currentPos.dx - textPainter.width,
          item.currentPos.dy,
        ),
      );

      if (settings.showAxis && i != 0) {
        Paint linePaint = Paint();
        linePaint.color = settings.axisColor;
        linePaint.strokeWidth = 1;
        linePaint.style = PaintingStyle.stroke;
        canvas.drawLine(
            Offset(sheetPainterData.position.dx, item.currentPos.dy + textPainter.height.half),
            Offset(sheetPainterData.position.dx + sheetPainterData.size.width, item.currentPos.dy + textPainter.height.half),
            linePaint);
      }
    }
  }
}

extension CanvasExt on Canvas {
  void drawDashLine(
    List<Offset> dataItems,
    double dashWidth, {
    Color color = Colors.white,
    double height = 4,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashWidth
      ..style = PaintingStyle.stroke;

    for (var element in dataItems) {
      drawLine(element + Offset(dashWidth / 2, 0), element + Offset(dashWidth / 2, height), paint);
    }
  }
}
