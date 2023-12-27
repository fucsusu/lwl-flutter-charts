import 'dart:ui';

/// Abstract class for touchable shape.
abstract class TouchableShape<T> {
  TouchableShape({this.data});

  /// The data of T.
  final T? data;

  /// Check object has been clicked.
  bool isHit(Offset offset);
}
