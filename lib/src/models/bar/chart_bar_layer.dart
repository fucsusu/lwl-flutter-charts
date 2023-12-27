import 'package:mrx_charts/src/models/animation/chart_animation.dart';
import 'package:mrx_charts/src/models/chart_data_item.dart';
import 'package:mrx_charts/src/models/chart_layer.dart';
import 'package:flutter/material.dart';

part 'chart_bar_data_item.dart';

part 'chart_bar_settings.dart';

/// This layer allows to render bars.
class ChartBarLayer extends ChartLayer {
  /// The items data of bars.
  final List<ChartBarDataItem> items;

  /// The settings of bars.
  final ChartBarSettings settings;

  ChartBarLayer({
    required this.items,
    required this.settings,
  }) {
    if (settings.waterfallBarDirection == WaterfallBarDirection.toRight) {
      double total = 0;
      for (var element in items) {
        total += element.value;
      }
      items.add(ChartBarDataItem(
        color: Colors.accents[items.length],
        value: total,
        x: items.length.toDouble() * settings.frequency,
      ));
    } else if (settings.waterfallBarDirection == WaterfallBarDirection.toLeft) {
      double total = 0;
      for (var element in items) {
        total += element.value;
        element.x = element.x + settings.frequency;
      }
      items.insert(
          0,
          ChartBarDataItem(
            color: Colors.accents[items.length + 1],
            value: total,
            x: 0,
          ));
    }
  }

  /// Disposing all animations.
  @override
  void dispose() {
    for (final ChartBarDataItem item in items) {
      item.dispose();
    }
  }
}
