import 'connection.dart';
import 'layer.dart';

class NeuralNetwork {
  final List<Layer> layers = List.empty(growable: true);

  void addInputLayer(int neuronAmount,
          num Function(num acc, int counter)? activationFunction) =>
      addLayer(neuronAmount, activationFunction,
          layerName: "Input", addBias: false);

  void addOutputLayer(int neuronAmount,
          num Function(num acc, int counter)? activationFunction) =>
      addLayer(neuronAmount, activationFunction,
          layerName: "Output", addBias: false);

  void addLayer(
      int neuronAmount, num Function(num acc, int counter)? activationFunction,
      {String layerName = "", bool addBias = true}) {
    final Layer newLayer = Layer(
      neuronAmount,
      null,
      layerName: layerName,
      addBias: addBias,
      activationFunction: activationFunction,
    );

    if (layers.isNotEmpty) {
      layers.last.addNextLayer(newLayer);
    }

    layers.add(newLayer);
  }

  List<num> get output => layers.last.values;

  List<num> refresh() {
    for (Layer layer in layers) {
      layer.propagate();
    }
    return layers.last.values;
  }

  List<num> predict(List<num> input) {
    assert(input.length == layers.first.length);

    layers.first.values = input;

    return refresh();
  }

  List<num> eval(List<num> input) {
    final originalValues = layers.first.values;

    final result = predict(input);

    layers.first.values = originalValues;

    predict(layers.first.values);

    return result;
  }

  bool updateConnectionWeight(String connectionName, num newWeight) {
    final connection = _getConnectionByName(connectionName);

    if (connection == null) {
      return false;
    }

    connection.weight = newWeight;
    refresh();
    return true;
  }

  Connection? _getConnectionByName(String name) {
    final layer = layers
        .where(
          (Layer layer) => layer.getConnectionByName(name) != null,
        )
        .firstOrNull;

    return layer?.getConnectionByName(name);
  }
}
