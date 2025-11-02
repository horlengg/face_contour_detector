
// 
import 'dart:ui';

class FaceBox {
  final int x;
  final int y;
  final int right;
  final int bottom;
  final double confidence;

  FaceBox({
    required this.x,
    required this.y,
    required this.right,
    required this.bottom,
    required this.confidence,
  });

  factory FaceBox.fromMap(Map<dynamic, dynamic> map) {
    return FaceBox(
      x: map['x'] as int,
      y: map['y'] as int,
      right: map['right'] as int,
      bottom: map['bottom'] as int,
      confidence: map['confidence'] as double,
    );
  }

  Rect get rect  => Rect.fromLTRB(x.toDouble(), y.toDouble(), right.toDouble(), bottom.toDouble());

  double get width => (right - x).toDouble();
  double get height => (bottom - y).toDouble();

  @override
  String toString() {
    return "left : $x, top: $y, right: $right, bottom: $bottom, width: $width, height: $height";
  }

}
