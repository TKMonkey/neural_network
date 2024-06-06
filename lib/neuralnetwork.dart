import 'connection.dart';
import 'layer.dart';

class NeuralNetwork {
  final List<Layer> layers = List.empty(growable: true);

  void addInputLayer(int neuronAmount,
          Function(num acc, int counter) activationFunction) =>
      addLayer(neuronAmount, activationFunction,
          layerName: "Input", addBias: false);

  void addOutputLayer(int neuronAmount,
          Function(num acc, int counter) activationFunction) =>
      addLayer(neuronAmount, activationFunction,
          layerName: "Output", addBias: false);

  void addLayer(
      int neuronAmount, Function(num acc, int counter) activationFunction,
      {String layerName = "", bool addBias = true}) {
    final Layer newLayer = Layer(
      neuronAmount,
      null,
      layerName: layerName,
      addBias: addBias,
    );

    if (layers.isNotEmpty) {
      layers.last.addNextLayer(newLayer);
    }

    layers.add(newLayer);
  }

  List<num> predict(List<num> input) {
    assert(input.length == layers.first.length);

    layers.first.values = input;
    layers.forEach((layer) {
      layer.propagate();
    });

    return layers.last.values;
  }

  bool updateConnectionWeight(String connectionName, num newWeight) {
    final connection = getConnectionByName(connectionName);

    if (connection != null) {
      connection.weight = newWeight;
      return true;
    } else {
      return false;
    }
  }

  Connection? getConnectionByName(String name) {
    final layer = layers
        .where(
          (Layer layer) => layer.getConnectionByName(name) != null,
        )
        .firstOrNull;

    return layer?.getConnectionByName(name);
  }
}
