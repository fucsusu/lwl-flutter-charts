import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

class LinePage extends StatefulWidget {
  const LinePage({Key? key}) : super(key: key);

  @override
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: GestureDetector(
              onTap: () => setState(() {}),
              child: const Icon(
                Icons.refresh,
                size: 26.0,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text('Line'),
      ),
      backgroundColor: const Color(0xFF1B0E41),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 400.0,
            maxWidth: 600.0,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Chart(
            layers: layers(),
            padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          ),
        ),
      ),
    );
  }

  List<ChartLayer> layers() {
    final from = DateTime(2021);
    final to = DateTime(2024);
    final frequency = (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / 3.0;
    return [
      ChartHighlightLayer(
        shape: () => ChartHighlightLineShape<ChartLineDataItem>(
          backgroundColor: const Color(0xFF331B6D),
          currentPos: (item) => item.currentValuePos,
          radius: const BorderRadius.all(Radius.circular(8.0)),
          width: 60.0,
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          centerX: true,
          x: ChartAxisSettingsAxis(
            showAxis: true,
            axisColor: Colors.white,
            frequency: frequency,
            max: to.millisecondsSinceEpoch.toDouble(),
            min: from.millisecondsSinceEpoch.toDouble(),
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            showAxis: true,
            axisColor: Colors.white.withAlpha(90),
            frequency: 100.0,
            max: 400.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('yy').format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineStackLayer([
        ChartLineLayer(
          items: List.generate(
            4,
            (index) => ChartLineDataItem(
              key: "index1",
              x: (index * frequency) + from.millisecondsSinceEpoch,
              value: index * 20 + Random().nextInt(40).toDouble(),
            ),
          ),
          settings: ChartLineSettings(
            color: const Color(0xFF8043F9),
            thickness: 2.0,
            name: "index1",
            useCurve: false,
            pointBuild: (offset, canvas) {
              Paint paint = Paint()
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = 1
                ..color = const Color(0xFFF9B043);
              canvas.drawCircle(offset, 2, paint);
            },
          ),
        ),
        ChartLineLayer(
          items: List.generate(
            4,
            (index) => ChartLineDataItem(
              key: "index2",
              x: (index * frequency) + from.millisecondsSinceEpoch,
              value: index * 30 + Random().nextInt(40).toDouble(),
            ),
          ),
          settings: ChartLineSettings(
            color: const Color(0xFFF96D43),
            thickness: 2.0,
            useCurve: false,
            name: "index2",
            pointBuild: (offset, canvas) {
              Paint paint = Paint()
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = 1
                ..color = const Color(0xFFAEEF2C);
              canvas.drawCircle(offset, 2, paint);
            },
          ),
        ),
        ChartLineLayer(
          items: List.generate(
            4,
            (index) => ChartLineDataItem(
              key: "index3",
              x: (index * frequency) + from.millisecondsSinceEpoch,
              value: index * 30 + Random().nextInt(40).toDouble(),
            ),
          ),
          settings: ChartLineSettings(
            color: const Color(0xFF43F9B3),
            thickness: 2.0,
            name: "index3",
            useCurve: false,
            pointBuild: (offset, canvas) {
              Paint paint = Paint()
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = 1
                ..color = const Color(0xFF2C6AEF);
              canvas.drawCircle(offset, 2, paint);
            },
          ),
        ),
      ]),
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Colors.white,
          circleBackgroundColor: Colors.white,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (key, item) => '$key:€${item.value.toString()}',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }
}
