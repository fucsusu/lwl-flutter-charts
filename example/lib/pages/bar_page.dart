import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mrx_charts/mrx_charts.dart';

class BarPage extends StatefulWidget {
  const BarPage({Key? key}) : super(key: key);

  @override
  State<BarPage> createState() => _BarPageState();
}

class _BarPageState extends State<BarPage> {
  int index = 5;
  bool showAxis = false;
  bool centerX = false;
  WaterfallBarDirection? waterfallBarDirection;

  Color barBackground = Colors.transparent;

  @override
  void initState() {
    super.initState();
    showAxis = true;
    centerX = true;
    barBackground = const Color(0x54EE7B3D);
    waterfallBarDirection = null;
  }

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
              onTap: () => changeChartLayout(),
              child: const Icon(
                Icons.refresh,
                size: 26.0,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text('Bar'),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 12.0),
          ),
        ),
      ),
    );
  }

  void changeChartLayout() {
    switch (index % 6) {
      case 0:
        showAxis = false;
        centerX = false;
        waterfallBarDirection = null;
        barBackground = Colors.transparent;
        break;
      case 1:
        showAxis = true;
        break;
      case 2:
        showAxis = true;
        centerX = true;
        break;
      case 3:
        showAxis = true;
        centerX = true;
        barBackground = const Color(0x54EE7B3D);
        break;
      case 4:
        showAxis = true;
        centerX = true;
        barBackground = const Color(0x54EE7B3D);
        waterfallBarDirection = WaterfallBarDirection.toLeft;
        break;
      case 5:
        showAxis = true;
        centerX = true;
        barBackground = const Color(0x54EE7B3D);
        break;
    }
    setState(() {});
  }

  List<ChartLayer> layers() {
    return [
      ChartAxisLayer(
        settings: ChartAxisSettings(
          centerX: centerX,
          x: ChartAxisSettingsAxis(
            showAxis: showAxis,
            frequency: 1.0,
            max: 7.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 300.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => value.toInt().toString(),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartBarLayer(
        items: List.generate(
          8,
          (index) => ChartBarDataItem(
            color: Colors.accents[index],
            value: Random().nextInt(50) + 50,
            x: index.toDouble(),
            gradient: LinearGradient(
              colors: [
                Colors.accents[index],
                Colors.accents[index + 4],
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        settings: ChartBarSettings(
          thickness: 10.0,
          touchThickness: 70,
          barBackground: barBackground,
          waterfallBarDirection: waterfallBarDirection,
          radius: const BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipBarShape<ChartBarDataItem>(
          backgroundColor: Colors.white,
          currentPos: (item) => item.currentValuePos,
          currentSize: (item) => item.currentValueSize,
          onTextValue: (item) => '€${item.value.toString()}',
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
