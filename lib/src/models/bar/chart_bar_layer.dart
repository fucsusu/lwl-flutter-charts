import 'package:mrx_charts/src/models/animation/chart_animation.dart';
import 'package:mrx_charts/src/models/chart_data_item.dart';
import 'package:mrx_charts/src/models/chart_layer.dart';
import 'package:flutter/material.dart';

import '../animation/chart_gradient_animation.dart';

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
    ///瀑布流数据处理
    if (settings.waterfallBarDirection == WaterfallBarDirection.toRight) {
      double total = 0;
      items.last.value = 0;
      for (var element in items) {
        total += element.value;
      }
      items.last.value = total;
    } else if (settings.waterfallBarDirection == WaterfallBarDirection.toLeft) {
      double total = 0;
      items.first.value = 0;
      for (var element in items) {
        total += element.value;
      }
      items.first.value = total;
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
