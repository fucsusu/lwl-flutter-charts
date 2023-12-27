import 'dart:ui';

import 'package:mrx_charts/src/models/touchable/touchable_shape.dart';

/// Provides touchable rectangle shape.
class RectangleShape<T> extends TouchableShape<T> {
  /// The position of rectangle.
  final Offset rectOffset;

  /// The size of rectangle.
  final Size rectSize;

  final List<T> dataList;

  RectangleShape({
    required this.rectOffset,
    required this.rectSize,
    this.dataList = const [],
  });

  void addItem(T t) {
    dataList.add(t);
  }

  /// Check rectangle has been clicked.
  @override
  bool isHit(Offset offset) {
    return rectOffset.dx <= offset.dx &&
        (rectOffset.dx + rectSize.width >= offset.dx) &&
        rectOffset.dy <= offset.dy &&
        (rectOffset.dy + rectSize.height >= offset.dy);
  }

  @override
  bool operator ==(Object other) {
    if (other is! RectangleShape) {
      return false;
    }
    return rectOffset == other.rectOffset && rectSize == other.rectSize && dataList == other.dataList;
  }

  @override
  int get hashCode => Object.hashAll([
        rectOffset,
        rectSize,
        dataList,
      ]);
}
