import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

class NNLayout extends GraphAlgorithm {
  int spaceBetweenLayers;

  NNLayout({super.decorators, this.spaceBetweenLayers = 150});

  @override
  void onGraphLoad(Graph graph) {
    var vertexes = graph.vertexes;

    final Map<String, List<Vertex<dynamic>>> neuronsIndexedByLayer = {};

    for (var vertex in vertexes) {
      final layerName = vertex.data["layerName"];
      final List<Vertex> currentList = neuronsIndexedByLayer[layerName] ?? [];
      currentList.add(vertex);
      neuronsIndexedByLayer[layerName] = currentList;
    }

    final sortedKeys = neuronsIndexedByLayer.keys
        .where((element) => element != "Input" && element != "Output")
        .toList()
      ..sort();
    final List<Vertex>? inputVertexes = neuronsIndexedByLayer["Input"];
    final List<Vertex>? outputVertexes = neuronsIndexedByLayer["Output"];

    double currentX = 50;
    locateVertexes(inputVertexes!, currentX);
    for (var hiddenLayerKey in sortedKeys) {
      currentX += spaceBetweenLayers;
      final List<Vertex>? hiddenLayerNeurons =
          neuronsIndexedByLayer[hiddenLayerKey];
      locateVertexes(hiddenLayerNeurons!, currentX);
    }

    locateVertexes(outputVertexes!, currentX + spaceBetweenLayers);
  }

  void locateVertexes(List<Vertex> vertexes, double initialX,
      [double heightPercentage = 0.7]) {
    vertexes.sort((Vertex a, Vertex b) {
      final String aName = a.data["neuronName"];
      final String bName = b.data["neuronName"];
      return aName.compareTo(bName);
    });
    double maxY = size?.height ?? 100;
    double currentYIncrement =
        (maxY * heightPercentage) / max(vertexes.length - 1, 2);
    final marginY = maxY * (1 - heightPercentage) / 2;
    double currentY = marginY;

    if (vertexes.length == 1) {
      vertexes.first.position = Vector2(initialX, center.dy);
      return;
    }

    for (var (index, vertex) in vertexes.indexed) {
      vertex.position = Vector2(initialX, currentY);
      if (index == vertexes.length - 2) {
        currentY = maxY - marginY;
      } else {
        currentY += currentYIncrement;
      }
    }
  }
}
