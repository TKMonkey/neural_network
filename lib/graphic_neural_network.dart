import 'dart:math';

import 'neural_network.dart';
import 'neuron.dart';

class GraphicNeuralNetwork {
  GraphicNeuralNetwork(this._neuralNetwork) {
    _initializeVertexesAndEdges();
  }

  final NeuralNetwork _neuralNetwork;
  final _vertexes = <String, Map<String, dynamic>>{};
  final _edges = <String, Map<String, dynamic>>{};

  Map<String, List<Map<String, dynamic>>> get data => {
        "vertexes": _vertexes.values.toList(),
        "edges": _edges.values.toList(),
      };

  void refresh() {
    _neuralNetwork.refresh();
    _updateVertexesAndEdges();
  }

  void setConnectionWeightByName(String connectionName, num newWeight) {
    _neuralNetwork.updateConnectionWeight(connectionName, newWeight);

    _updateVertexesAndEdges();
  }

  void _updateVertexesAndEdges() {
    for (var layer in _neuralNetwork.layers) {
      int neuronsInLayer = layer.length;
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        _vertexes[neuron.fullName]!["currentValue"] = neuron.value;
      }
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        for (var connection in neuron.connections) {
          _edges[connection.name]!["weight"] = connection.weight.toDouble();
        }
      }
    }
  }

  void _initializeVertexesAndEdges() {
    for (var layer in _neuralNetwork.layers) {
      int neuronsInLayer = layer.length;
      for (var neuronIndex = 0; neuronIndex < neuronsInLayer; neuronIndex++) {
        final Neuron neuron = layer[neuronIndex];
        _vertexes.addEntries([
          MapEntry(neuron.fullName, {
            "id": neuron.fullName,
            "tag": "tag8",
            "currentValue": neuron.value,
            "layerName": neuron.layerName,
            "neuronName": neuron.nameInsideLayer
          })
        ]);

        for (var connection in neuron.connections) {
          if (_edges.containsKey(connection.name)) {
            continue;
          }
          _edges.addEntries([
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
