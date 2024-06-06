import 'dart:math';

import 'neuralnetwork.dart';
import 'neuron.dart';

class GraphicNeuralNetwork {
  GraphicNeuralNetwork(this.neuralNetwork) {
    _initializeVertexesAndEdges();
  }

  final NeuralNetwork neuralNetwork;
  final vertexes = <String, Map<String, dynamic>>{};
  final edges = <String, Map<String, dynamic>>{};

  Map<String, List<Map<String, dynamic>>> get data => {
        "vertexes": vertexes.values.toList(),
        "edges": edges.values.toList(),
      };

  void setConnectionWeightByName(String connectionName, num newWeight) {
    final connection = neuralNetwork.getConnectionByName(connectionName);

    if (connection == null) {
      return;
    }

    connection.weight = newWeight;

    neuralNetwork.predict([10]);

    _updateVertexesAndEdges();
  }

  void _updateVertexesAndEdges() {
    for (var layer in neuralNetwork.layers) {
      int neuronsInLayer = layer.length;
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        vertexes[neuron.fullName]!["currentValue"] = neuron.value;
      }
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        for (var connection in neuron.connections) {
          edges[connection.name]!["weight"] = connection.weight.toDouble();
        }
      }
    }
  }

  void _initializeVertexesAndEdges() {
    for (var layer in neuralNetwork.layers) {
      int neuronsInLayer = layer.length;
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        vertexes.addEntries([
          MapEntry(neuron.fullName, {
            "id": neuron.fullName,
            "tag": "tag8",
            "currentValue": neuron.value,
            "layerName": neuron.layerName,
            "neuronName": neuron.nameInsideLayer
          })
        ]);

        for (var connection in neuron.connections) {
          if (edges.containsKey(connection.name)) {
            continue;
          }
          edges.addEntries([
            MapEntry(connection.name, {
              "srcId": neuron.fullName,
              "dstId": connection.upperLayerNeuronName,
              "edgeName": connection.name,
              "ranking": Random().nextInt(1000),
              "weight": connection.weight.toDouble(),
              "learningDelta": null
            })
          ]);
        }
      }
    }
  }
}
