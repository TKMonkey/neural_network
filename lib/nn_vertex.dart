import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class NNVertex extends VertexCircleShape {
  @override
  render(Vertex vertex, Canvas canvas, Paint paint, List<Paint> paintLayers) {
    canvas.drawCircle(
        Offset(vertex.radiusZoom, vertex.radiusZoom),
        vertex.radiusZoom * 4,
        paint
          ..shader = null
          ..color = vertex.colors.first);
    // 渲染标题
    if (vertex.cpn?.options?.showText ??
        true && vertex.cpn!.game.camera.viewfinder.zoom > 0.3) {
      textRenderer?.render(vertex, canvas, paint);
    }

    final textPainter = TextPainter(
        text: TextSpan(
          text: vertex.data["currentValue"]?.toStringAsFixed(2),
          style: const TextStyle(color: Colors.white),
        ),
        textDirection: TextDirection.ltr);

    textPainter.layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    textPainter.paint(
      canvas,
      Offset(vertex.radiusZoom - textWidth / 2,
          vertex.radiusZoom - textHeight / 2),
    );
  }
}
