import 'package:flutter/cupertino.dart';

import '../mrx_charts.dart';

/// Widget of charts.
class Chart extends StatefulWidget {
  /// The duration of the chart animations.
  ///
  /// Defaults to Duration(milliseconds: 300)
  final Duration duration;

  /// The layers of charts.
  final List<ChartLayer> layers;

  /// The padding of charts.
  ///
  /// Defaults to EdgeInsets.zero
  final EdgeInsets padding;

  const Chart({
    this.duration = const Duration(
      milliseconds: 400,
    ),
    this.layers = const [],
    this.padding = EdgeInsets.zero,
    Key? key,
  }) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  late final AnimationController _controller;
  List<ChartLayer>? oldLayers;
  List<TouchableShape<ChartDataItem>> _touchableShapes = [];
  ChartTouchCallbackData? _touchedData;

  ///缩放中心
  ChartTouchCallbackData? _scaleCenterData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller
        ..stop()
        ..reset()
        ..forward(),
    );
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    if (widget.layers != oldWidget.layers) {
      setState(() {
        oldLayers = oldWidget.layers;
        _touchedData = null;
        _scaleCenterData = null;
        _disposeOldLayers();
        _controller
          ..stop()
          ..reset()
          ..forward();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //缩放处理数据
    List<ChartLayer> layers = scaleProcessLayers(widget.layers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ChartTouchDetector<ChartDataItem>(
              onShapes: () => _touchableShapes,
              onTap: ((touchPosition, data) => setState(() {
                    _touchedData = data == null
                        ? null
                        : ChartTouchCallbackData(
                            clickedPos: touchPosition,
                            selectedItem: data,
                          );
                  })),
              onDoubleTap: (touchPosition, data) {
                _scaleCenterData = data == null
                    ? null
                    : ChartTouchCallbackData(
                        clickedPos: touchPosition,
                        selectedItem: data,
                        scaleCount: (_scaleCenterData?.scaleCount ?? 0) + 1,
                      );
              },
              child: CustomPaint(
                painter: ChartPainter(
                  controller: _controller,
                  layers: layers,
                  oldLayers: oldLayers,
                  onUpdateTouchableShapes: (shapes) => _touchableShapes = shapes,
                  padding: widget.padding,
                  touchedData: _touchedData,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _disposeOldLayers() {
    for (final ChartLayer layer in oldLayers ?? []) {
      layer.dispose();
    }
  }

  List<ChartLayer> scaleProcessLayers(List<ChartLayer> layers) {
    List<ChartLayer> tempLayers = List<ChartLayer>.from(layers);
    if (_scaleCenterData != null) {
      //先处理数据
      final ChartLayer? chartBarLayer = tempLayers.firstWhereOrNull((element) => element is ChartBarLayer);
      final ChartLayer? charAxisLayer = tempLayers.firstWhereOrNull((element) => element is ChartAxisLayer);

      int scaleCount = _scaleCenterData!.scaleCount;
      bool lackData = false;
      if (chartBarLayer is ChartBarLayer && charAxisLayer is ChartAxisLayer) {
        if (chartBarLayer.items.length < charAxisLayer.x.items.length) {
          charAxisLayer.x.min = chartBarLayer.minX;
          charAxisLayer.x.max = chartBarLayer.maxX;
          charAxisLayer.updateXChartAxisData();
          scaleCount--;
          lackData = true;
        }

        if (chartBarLayer.items.length > 1) {
          int residueScale = 1;
          if (scaleCount <= chartBarLayer.items.length ~/ 2) {
            residueScale = (chartBarLayer.items.length ~/ 2 - scaleCount) * 2 + 1;
          } else {
            scaleCount = chartBarLayer.items.length ~/ 2;
            if (lackData) {
              scaleCount++;
            }
          }
          chartBarLayer.updateItemsByCenter(_scaleCenterData!.selectedItem, residueScale);
        }
      }
    }
    return tempLayers;
  }
}

extension _ListExtensions<T> on List<T> {
  // List<T> copy() => [...this];
  //
  // T? get firstOrNull => isNotEmpty ? first : null;
  //
  // T? get lastOrNull => isNotEmpty ? last : null;
  //
  // T? getOrNull(int index) => length > index ? this[index] : null;

  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
