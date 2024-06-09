import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class NNEdgeLineShape extends EdgeLineShape {
  @override
  void vertexDifferent(Edge edge, Canvas canvas, Paint paint) {
    super.vertexDifferent(edge, canvas, paint);

    var startPoint = Offset.zero;
    var endPoint = Offset(len(edge), paint.strokeWidth);

    final double? weight = edge.data["weight"];

    if (weight != null) {
      _addWeight(startPoint, endPoint, weight, canvas);
    }

    final double? learningDelta = edge.data["learningDelta"];
    if (learningDelta != null) {
      _addLearningDelta(startPoint, endPoint, learningDelta, canvas);
    }
  }

  void _addWeight(
      Offset startPoint, Offset endPoint, double weight, Canvas canvas) {
    final text = "W: ${weight.toStringAsFixed(2)} -->";

    Offset getFinalTextPosition(double textWidth, double textHeight) => Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx) / 2 - textWidth / 2,
          startPoint.dy +
              (endPoint.dy - startPoint.dy) / 2 -
              textHeight / 2 -
              10,
        );

    _addLabel(
        getFinalTextPosition: getFinalTextPosition,
        value: text,
        canvas: canvas);
  }

  void _addLearningDelta(
      Offset startPoint, Offset endPoint, double learningDelta, Canvas canvas) {
    final text = "<- LD: ${learningDelta.toStringAsFixed(3)}";

    Offset getFinalTextPosition(double textWidth, double textHeight) => Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx) / 2 - textWidth / 2,
          startPoint.dy +
              (endPoint.dy - startPoint.dy) / 2 -
              textHeight / 2 +
              10,
        );

    _addLabel(
      getFinalTextPosition: getFinalTextPosition,
      value: text,
      canvas: canvas,
      textStyle: const TextStyle(
        color: Colors.green,
        fontSize: 15,
      ),
    );
  }

  void _addLabel({
    required Offset Function(double finalTextWidth, double finalTextHeight)
        getFinalTextPosition,
    required String value,
    required Canvas canvas,
    textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 15,
    ),
  }) {
    final textPainter = TextPainter(
        text: TextSpan(
          text: value,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr);

    textPainter.layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    textPainter.paint(
      canvas,
      getFinalTextPosition(textWidth, textHeight),
    );
  }
}
