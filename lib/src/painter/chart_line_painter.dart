part of 'chart_painter.dart';

/// Layer painter for line.
class _ChartLinePainter {
  const _ChartLinePainter._();

  /// 绘制叠层图
  static void drawStack({
    required Canvas canvas,
    required AnimationController controller,
    required ChartLineStackLayer layer,
    required ChartPainterData painterData,
    required List<TouchableShape<ChartDataItem>> touchableShapes,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartLineStackLayer? oldLayer,
  }) {
    Paint tipsPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    if (layer.items.isNotEmpty) {
      Path? prePath;
      Offset tipsOffset = Offset(painterData.position.dx, topDataTypeHeight / 2);
      Map<int, TouchableShape<ChartDataItem>> touchableShapesTemp = {};

      for (int i = 0; i < layer.items.length; i++) {
        ChartLineLayer lineLayer = layer.items[i];

        for (int j = 0; j < lineLayer.items.length; j++) {
          ChartLineDataItem item = lineLayer.items[j];
          _calculate(
            controller: controller,
            item: item,
            oldItem: oldLayer?.items[i].items.getOrNull(j),
            oldLayer: oldLayer?.items[i],
            painterData: painterData,
            settings: lineLayer.settings,
            xValue: xValue,
            yValue: yValue,
          );
        }
        prePath = _drawPath(canvas: canvas, layer: lineLayer, painterData: painterData, prePath: prePath);

        for (int i = 0; i < lineLayer.items.length; i++) {
          /// 绘制点位
          lineLayer.settings.pointBuild?.call(lineLayer.items[i].currentValuePos, canvas);
        }

        /// 绘制顶部示例
        tipsOffset = _drawTopExample(canvas, painterData, tipsPaint, lineLayer, tipsOffset);

        /// 计算点击范围
        final double v1 = (lineLayer.items.getOrNull(1)?.currentValuePos)?.dx ?? 0.0;
        final double v2 = (lineLayer.items.firstOrNull?.currentValuePos)?.dx ?? 0.0;
        final double weight = (max(v1, v2) - min(v1, v2)) * 0.9;

        for (int j = 0; j < lineLayer.items.length; j++) {
          final ChartLineDataItem item = lineLayer.items[j];
          _calculateTouch(
            controller: controller,
            item: item,
            oldItem: oldLayer?.items[i].items.getOrNull(j),
            painterData: painterData,
            weight: weight,
          );

          if (touchableShapesTemp.keys.contains(j)) {
            (touchableShapesTemp[j] as RectangleShape).addItem(item);
          } else {
            touchableShapesTemp.putIfAbsent(
                j,
                () => RectangleShape<ChartLineDataItem>(
                    dataList: [item], rectOffset: item.currentTouchPos, rectSize: item.currentTouchSize));
          }
        }
      }
      touchableShapes.addAll(touchableShapesTemp.values);

      ///绘制辅助线
      // Paint paint = Paint()
      //   ..color = Colors.white
      //   ..style = PaintingStyle.stroke;
      //
      // canvas.drawCircle(painterData.position, 3, paint);
      // canvas.drawRect(
      //     Rect.fromPoints(
      //         painterData.position, painterData.position + Offset(painterData.size.width, painterData.size.height)),
      //     paint);
    }
  }

  /// Draw line.
  static void draw({
    required Canvas canvas,
    required AnimationController controller,
    required ChartLineLayer layer,
    required ChartPainterData painterData,
    required List<TouchableShape<ChartDataItem>> touchableShapes,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartLineLayer? oldLayer,
  }) {
    for (int i = 0; i < layer.items.length; i++) {
      final ChartLineDataItem item = layer.items[i];
      _calculate(
        controller: controller,
        item: item,
        oldItem: (oldLayer?.items)?.getOrNull(i),
        oldLayer: oldLayer,
        painterData: painterData,
        settings: layer.settings,
        xValue: xValue,
        yValue: yValue,
      );
    }

    _drawPath(canvas: canvas, layer: layer, painterData: painterData);

    /// 计算点击位置宽度
    final double v1 = (layer.items.getOrNull(1)?.currentValuePos)?.dx ?? 0.0;
    final double v2 = (layer.items.firstOrNull?.currentValuePos)?.dx ?? 0.0;
    final double weight = (max(v1, v2) - min(v1, v2)) * 0.9;

    for (int i = 0; i < layer.items.length; i++) {
      final ChartLineDataItem item = layer.items[i];
      _calculateTouch(
        controller: controller,
        item: item,
        oldItem: (oldLayer?.items)?.getOrNull(i),
        painterData: painterData,
        weight: weight,
      );
      touchableShapes.add(
        RectangleShape<ChartLineDataItem>(
          dataList: [item],
          rectOffset: item.currentTouchPos,
          rectSize: item.currentTouchSize,
        ),
      );
    }
  }

  static void _calculate({
    required AnimationController controller,
    required ChartLineDataItem item,
    required ChartPainterData painterData,
    required ChartLineSettings settings,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartLineLayer? oldLayer,
    ChartLineDataItem? oldItem,
  }) {
    final double offsetX = painterData.size.width * (item.x - xValue.min) / (xValue.max - xValue.min);
    final Offset pos = Offset(
      painterData.position.dx + offsetX,
      painterData.position.dy +
          painterData.size.height -
          (painterData.size.height * (item.value - yValue.min) / (yValue.max - yValue.min)),
    );
    final ChartLineDataItem? oldItemLast = (oldLayer?.items)?.lastOrNull;
    item.setupValue(
      controller: controller,
      color: settings.color,
      initialColor: oldItem?.lastValueColor ?? Colors.transparent,
      initialPos: oldItem?.lastValuePos ??
          (oldItemLast != null
              ? Offset(painterData.position.dx + painterData.size.width, oldItemLast.lastValuePos.dy)
              : Offset(pos.dx, painterData.position.dy + painterData.size.height)),
      pos: pos,
      oldItem: oldItem,
    );
  }

  static void _calculateTouch({
    required AnimationController controller,
    required ChartLineDataItem item,
    required ChartPainterData painterData,
    required double weight,
    ChartLineDataItem? oldItem,
  }) {
    final Size size = Size(
      weight,
      painterData.size.height,
    );
    final Offset pos = Offset(
      item.currentValuePos.dx - weight.half,
      painterData.position.dy,
    );
    item.setupTouch(
      controller: controller,
      initialPos: oldItem?.lastTouchPos ?? pos,
      initialSize: oldItem?.lastTouchSize ?? size,
      oldItem: oldItem,
      pos: pos,
      size: size,
    );
  }

  static Path _drawPath({
    required Canvas canvas,
    required ChartLineLayer layer,
    required ChartPainterData painterData,
    Path? prePath,
  }) {
    final Paint paint = Paint()
      ..strokeWidth = layer.settings.thickness
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = layer.settings.color;

    Path drawPath;
    if (layer.settings.useCurve) {
      drawPath = _drawCurvePath(canvas: canvas, layer: layer, paint: paint);
    } else {
      drawPath = _drawStraightPath(canvas: canvas, layer: layer, paint: paint);
    }

    if (layer.settings.useArea) {
      ChartLineDataItem firstItem = layer.items.first;
      ChartLineDataItem lastItem = layer.items.last;
      double bottomDy = painterData.size.height + painterData.position.dy;
      drawPath.lineTo(lastItem.currentValuePos.dx, bottomDy);
      drawPath.lineTo(firstItem.currentValuePos.dx, bottomDy);
      drawPath.close();
      if (prePath != null) {
        drawPath = Path.combine(PathOperation.difference, drawPath, prePath);
      }
      paint.style = PaintingStyle.fill;
      paint.color = layer.settings.color.withAlpha(80);
      canvas.drawPath(drawPath, paint);
    }
    drawPath = drawPath.shift(const Offset(0, -1));
    return drawPath;
  }

  static Path _drawCurvePath({
    required Canvas canvas,
    required ChartLineLayer layer,
    required Paint paint,
  }) {
    final Path curvePath = Path();

    late Offset previousPos;
    for (int i = 0; i < layer.items.length; i++) {
      final ChartLineDataItem lineItem = layer.items[i];
      final Offset currentPos = lineItem.currentValuePos;
      if (i < 1) {
        curvePath.moveTo(currentPos.dx, currentPos.dy);
      } else {
        final Offset controlPos = Offset(previousPos.dx + (currentPos.dx - previousPos.dx).half, previousPos.dy);
        final Offset controlPos2 = Offset(currentPos.dx + (previousPos.dx - currentPos.dx).half, currentPos.dy);

        curvePath.cubicTo(controlPos.dx, controlPos.dy, controlPos2.dx, controlPos2.dy, currentPos.dx, currentPos.dy);
      }
      previousPos = currentPos;
    }
    canvas.drawPath(curvePath, paint..color = layer.items.firstOrNull?.currentValueColor ?? Colors.transparent);
    return curvePath;
  }

  static Path _drawStraightPath({
    required Canvas canvas,
    required ChartLineLayer layer,
    required Paint paint,
  }) {
    final Path straightPath = Path();
    for (int i = 0; i < layer.items.length; i++) {
      final ChartLineDataItem lineItem = layer.items[i];
      final Offset currentPos = lineItem.currentValuePos;
      if (i < 1) {
        straightPath.moveTo(currentPos.dx, currentPos.dy);
      } else {
        straightPath.lineTo(currentPos.dx, currentPos.dy);
      }
    }
    canvas.drawPath(straightPath, paint..color = layer.items.firstOrNull?.currentValueColor ?? Colors.transparent);
    return straightPath;
  }

  /// 绘制顶部示例
  static Offset _drawTopExample(
      Canvas canvas, ChartPainterData painterData, Paint tipsPaint, ChartLineLayer lineLayer, Offset offset) {
    tipsPaint.color = lineLayer.settings.color;
    tipsPaint.strokeWidth = 2;
    canvas.drawLine(offset + const Offset(0, 5), offset + const Offset(10, 5), tipsPaint);
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: lineLayer.settings.name,
        style: lineLayer.settings.nameStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset + const Offset(15, 0));
    offset = offset + Offset(20 + textPainter.width, 0);
    return offset;
  }
}
