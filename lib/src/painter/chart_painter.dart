import 'dart:math';

import 'package:flutter/material.dart';

import '../../mrx_charts.dart';

part 'chart_axis_painter.dart';

part 'chart_bar_painter.dart';

part 'chart_candle_painter.dart';

part 'chart_grid_painter.dart';

part 'chart_group_bar_painter.dart';

part 'chart_group_pie_painter.dart';

part 'chart_highlight_painter.dart';

part 'chart_line_painter.dart';

part 'chart_tooltip_painter.dart';

typedef UpdateTouchableShapesCallback = void Function(List<TouchableShape<ChartDataItem>> touchableShapes);

/// 数据类型显示区域
int topDataTypeHeight = 30;

/// Provides chart painter.
class ChartPainter extends CustomPainter {
  ChartPainter({
    required this.controller,
    required this.layers,
    this.padding = EdgeInsets.zero,
    this.oldLayers,
    this.onUpdateTouchableShapes,
    this.touchedData,
  });

  /// The controller from animation.
  final AnimationController controller;

  /// The list of layers.
  final List<ChartLayer> layers;

  /// The padding of main sheet.
  final EdgeInsets padding;

  /// The previous layers.
  final List<ChartLayer>? oldLayers;

  ///Only used if graph uses a touch events
  final UpdateTouchableShapesCallback? onUpdateTouchableShapes;

  /// The touchedData has been last clicked.
  final ChartTouchCallbackData? touchedData;

  ChartPainterData _axisXPainterData = const ChartPainterData.empty();
  ChartPainterData _axisYPainterData = const ChartPainterData.empty();
  ChartPainterData _sheetPainterData = const ChartPainterData.empty();

  /// Draw charts.
  @override
  void paint(Canvas canvas, Size size) {
    final ChartTouchCallbackData? currentTouchedData = touchedData;
    _calculate(size);
    ChartAxisValue xValue = const ChartAxisValue.empty();
    ChartAxisValue yValue = const ChartAxisValue.empty();
    final ChartLayer? axisLayer = layers.firstWhereOrNull((element) => element is ChartAxisLayer);
    final List<TouchableShape<ChartDataItem>> touchableShapes = [];
    if (axisLayer is ChartAxisLayer) {
      xValue = ChartAxisValue(
        max: axisLayer.x.max,
        min: axisLayer.x.min,
      );
      yValue = ChartAxisValue(
        max: axisLayer.y.max,
        min: axisLayer.y.min,
      );
    }

    for (int i = 0; i < layers.length; i++) {
      final ChartLayer layer = layers[i];
      final ChartLayer? oldLayer = oldLayers?.getOrNull(i);
      if (layer is ChartGridLayer) {
        _ChartGridPainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartGridLayer ? oldLayer : null,
          painterData: _sheetPainterData,
        );
      } else if (layer is ChartAxisLayer) {
        _ChartAxisPainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartAxisLayer ? oldLayer : null,
          painterDataAxisX: _axisXPainterData,
          painterDataAxisY: _axisYPainterData,
          sheetPainterData: _sheetPainterData,
        );
      } else if (layer is ChartBarLayer) {
        _ChartBarPainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartBarLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          touchableShapes: touchableShapes,
          xValue: xValue,
          yValue: yValue,
        );
      } else if (layer is ChartLineLayer) {
        _ChartLinePainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartLineLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          touchableShapes: touchableShapes,
          xValue: xValue,
          yValue: yValue,
        );
      } else if (layer is ChartLineStackLayer) {
        _ChartLinePainter.drawStack(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartLineStackLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          touchableShapes: touchableShapes,
          xValue: xValue,
          yValue: yValue,
        );
      } else if (layer is ChartGroupBarLayer) {
        _ChartGroupBarPainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartGroupBarLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          touchableShapes: touchableShapes,
          xValue: xValue,
          yValue: yValue,
        );
      } else if (layer is ChartGroupPieLayer) {
        _ChartGroupPiePainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartGroupPieLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          touchableShapes: touchableShapes,
        );
      } else if (layer is ChartCandleLayer) {
        _ChartCandlePainter.draw(
          canvas: canvas,
          controller: controller,
          layer: layer,
          oldLayer: oldLayer is ChartCandleLayer ? oldLayer : null,
          painterData: _sheetPainterData,
          xValue: xValue,
          yValue: yValue,
        );
      } else if (layer is ChartTooltipLayer && currentTouchedData != null) {
        _ChartTooltipPainter.draw(
          canvas: canvas,
          layer: layer,
          painterData: _sheetPainterData,
          tolerance: _sheetPainterData.position.dx - (_axisYPainterData.position.dx + _axisYPainterData.size.width),
          touchedData: currentTouchedData,
        );
      } else if (layer is ChartHighlightLayer && currentTouchedData != null) {
        _ChartHighlightPainter.draw(
          canvas: canvas,
          layer: layer,
          painterData: _sheetPainterData,
          tolerance: _sheetPainterData.position.dx - (_axisYPainterData.position.dx + _axisYPainterData.size.width),
          touchedData: currentTouchedData,
        );
      }
    }
    onUpdateTouchableShapes?.call(touchableShapes);
  }

  /// 计算基础数据
  void _calculate(Size size) {
    final ChartLayer? axisLayer = layers.firstWhereOrNull(
      (element) => element is ChartAxisLayer,
    );
    double maxAxisXHeight = 0.0;
    double maxAxisYWidth = 0.0;
    List<TextPainter> axisXTextPainters = [];
    List<TextPainter> axisYTextPainters = [];
    if (axisLayer is ChartAxisLayer) {
      axisXTextPainters = _generateTextPainters(axisLayer.x.items, axisLayer.settings.x.textStyle);
      axisYTextPainters = _generateTextPainters(axisLayer.y.items, axisLayer.settings.y.textStyle);
    }
    maxAxisXHeight = axisXTextPainters.biggestHeight;
    maxAxisYWidth = axisYTextPainters.biggestWidth;
    final double axisXTextPainterFirstWidth = axisXTextPainters.firstWidthOrZero;
    final double axisXTextPainterLastWidth = axisXTextPainters.lastWidthOrZero;
    final double axisYTextPainterFirstHeight = axisYTextPainters.firstHeightOrZero;
    final double axisYTextPainterLastHeight = axisYTextPainters.lastHeightOrZero;
    EdgeInsets paddingHorizontal = EdgeInsets.zero;
    paddingHorizontal = EdgeInsets.symmetric(
      horizontal: [
            _findBarWidthBiggest(),
            _findGroupBarWidthBiggest(),
          ].sorted((a, b) => a.compareTo(b)).lastOrNull ??
          0.0,
    );

    /// 是否是堆积图
    bool hasStackLayer = layers.firstWhereOrNull((element) => element is ChartLineStackLayer) != null;

    _sheetPainterData = ChartPainterData(
      position: Offset(
        maxAxisYWidth + axisXTextPainterFirstWidth.half + paddingHorizontal.left.half + padding.left,
        hasStackLayer
            ? axisYTextPainterLastHeight.half + padding.top + topDataTypeHeight
            : axisYTextPainterLastHeight.half + padding.top,
      ),
      size: Size(
        size.width -
            maxAxisYWidth -
            axisXTextPainterFirstWidth.half -
            axisXTextPainterLastWidth.half -
            paddingHorizontal.horizontal.half -
            padding.horizontal,
        size.height -
            maxAxisXHeight -
            axisYTextPainterLastHeight.half -
            axisYTextPainterFirstHeight.half -
            padding.vertical -
            topDataTypeHeight,
      ),
    );

    _axisXPainterData = ChartPainterData(
      position: Offset(
        _sheetPainterData.position.dx,
        _sheetPainterData.position.dy + _sheetPainterData.size.height + axisYTextPainterFirstHeight.half + padding.bottom,
      ),
      size: Size(
        _sheetPainterData.size.width,
        maxAxisXHeight,
      ),
    );
    _axisYPainterData = ChartPainterData(
      position: Offset(
        0.0,
        _sheetPainterData.position.dy,
      ),
      size: Size(
        maxAxisYWidth,
        _sheetPainterData.size.height,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  List<TextPainter> _generateTextPainters(
    List<ChartAxisDataItem> items,
    TextStyle textStyle,
  ) {
    return items
        .map(
          (item) => TextPainter(
            text: TextSpan(
              text: item.label,
              style: textStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(),
        )
        .toList();
  }

  double _findBarWidthBiggest() {
    return layers
            .whereType<ChartBarLayer>()
            .map(
              (e) => e.settings.thickness,
            )
            .sorted((a, b) => a.compareTo(b))
            .lastOrNull ??
        0.0;
  }

  double _findGroupBarWidthBiggest() {
    return layers
            .whereType<ChartGroupBarLayer>()
            .map(
              (e) {
                final int maxIndex = e.items.firstOrNull?.length ?? 0;
                return maxIndex * e.settings.thickness + (maxIndex - 1) * e.settings.paddingBetweenItems;
              },
            )
            .sorted((a, b) => a.compareTo(b))
            .lastOrNull ??
        0.0;
  }
}

extension _DoubleExtensions on double {
  double get half => this / 2.0;
}

extension _ListExtensions<T> on List<T> {
  List<T> copy() => [...this];

  T? get firstOrNull => isNotEmpty ? first : null;

  T? get lastOrNull => isNotEmpty ? last : null;

  T? getOrNull(int index) => length > index ? this[index] : null;

  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension _IterableExtensions<T> on Iterable<T> {
  List<T> copy() => [...this];

  List<T> sorted(Comparator<T> compare) => copy()..sort(compare);
}

extension _IterableDoubleExtensions on Iterable<double> {
  double get sum {
    double result = 0.0;
    for (double value in this) {
      result += value;
    }
    return result;
  }
}

extension _ListTextPainterExtensions on List<TextPainter> {
  double get biggestHeight => isNotEmpty ? (copy()..sort((a, b) => a.height.compareTo(b.height))).last.height : 0.0;

  double get biggestWidth => isNotEmpty ? (copy()..sort((a, b) => a.width.compareTo(b.width))).last.width : 0.0;

  double get firstHeightOrZero => isNotEmpty ? first.height : 0.0;

  double get lastHeightOrZero => isNotEmpty ? last.height : 0.0;

  double get firstWidthOrZero => isNotEmpty ? first.width : 0.0;

  double get lastWidthOrZero => isNotEmpty ? last.width : 0.0;
}
