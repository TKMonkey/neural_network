import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'connection_weight_slider.dart';
import 'graphic_neural_network.dart';
import 'nn_edge_line_shape.dart';
import 'nn_layout.dart';
import 'nn_vertex.dart';
import 'platform_extension.dart';

class NeuralNetworkWidget extends StatelessWidget {
  final GraphicNeuralNetwork nn;
  final Function(Edge? edge)? setEdge;
  final Function(double value)? setValue;

  const NeuralNetworkWidget({
    super.key,
    required this.nn,
    this.setEdge,
    this.setValue,
  });

  @override
  Widget build(BuildContext context) {
    final data = nn.data;

    return FlutterGraphWidget(
      data: data,
      algorithm: NNLayout(
        spaceBetweenLayers: !isMobile ? 300 : 150,
        decorators: [],
      ),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..panelDelay = Duration.zero
        ..showText = true
        ..textGetter = (vertex) {
          return "";
        }
        ..graphStyle = (GraphStyle()
          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
          ..tagColor = {'tag8': Colors.orangeAccent.shade200}
          ..tagColorByIndex = [
            Colors.red.shade200,
            Colors.orange.shade200,
            Colors.yellow.shade200,
            Colors.green.shade200,
            Colors.blue.shade200,
            Colors.blueAccent.shade200,
            Colors.purple.shade200,
            Colors.pink.shade200,
            Colors.blueGrey.shade200,
            Colors.deepOrange.shade200,
          ])
        ..useLegend = true // default true
        ..edgePanelBuilder = edgePanelBuilder
        // ..vertexPanelBuilder = vertexPanelBuilder
        ..edgeShape = NNEdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = NNVertex() // default is VertexCircleShape.
        ..backgroundBuilder =
            (BuildContext context) => Container(color: Colors.white),
    );
  }

  Widget edgePanelBuilder(Edge edge, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(edge.position);
    setEdge?.call(edge);

    if (!isMobile) {
      return Positioned(
        left: c.x - 100,
        top: c.y, // + 50,
        child: ConnectionWeightSlider(
          edge,
          (value) {
            setEdge?.call(edge);
            setValue?.call(value);
          },
        ),
      );
    } else {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
  }
}
