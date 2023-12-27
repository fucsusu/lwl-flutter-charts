import 'package:mrx_charts/src/models/touchable/touchable_shape.dart';
import 'package:flutter/widgets.dart';

import '../../mrx_charts.dart';

/// Provides touch detector.
class ChartTouchDetector<T> extends StatefulWidget {
  final Widget? child;

  /// The function reacted by tap on widget.
  final void Function(Offset touchPosition, T? data)? onTap;

  /// The list of shapes.
  final List<TouchableShape<T>>? shapes;

  /// The function return list of shapes.
  final List<TouchableShape<T>> Function() onShapes;

  const ChartTouchDetector({
    required this.onShapes,
    this.child,
    this.onTap,
    this.shapes,
    Key? key,
  }) : super(key: key);

  @override
  State<ChartTouchDetector<T>> createState() => _ChartTouchDetectorState<T>();
}

class _ChartTouchDetectorState<T> extends State<ChartTouchDetector<T>> {
  int shapeIndex = 0;

  int lastIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails tapUpDetails) {
        if (widget.onTap == null) {
          return;
        }
        List shapes = widget.onShapes();
        for (int i = 0; i < shapes.length; i++) {
          TouchableShape<T> shape = shapes[i];
          if (shape is RectangleShape) {
            if (shape.isHit(tapUpDetails.localPosition)) {
              if (shapeIndex == i) {
                lastIndex++;
                if (lastIndex >= (shape as RectangleShape).dataList.length) {
                  lastIndex = 0;
                }
              } else {
                shapeIndex = i;
                lastIndex = 0;
              }
              widget.onTap?.call(tapUpDetails.localPosition, (shape as RectangleShape).dataList[lastIndex]);
              return;
            }
          } else {
            if (shape.isHit(tapUpDetails.localPosition)) {
              widget.onTap?.call(tapUpDetails.localPosition, shape.data);
              return;
            }
          }
        }
        widget.onTap?.call(tapUpDetails.localPosition, null);
      },
      child: widget.child,
    );
  }
}
