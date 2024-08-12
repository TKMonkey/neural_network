import 'package:untitled/neural_network.dart';

import 'input_and_expected_output.dart';
import 'layer.dart';

class ManualNeuralNetwork implements NeuralNetwork {
  final NeuralNetwork _nn;
  int _currentTrainingDataIndex = -1;
  List<InputAndExpectedOutput> _trainingData = [];

  ManualNeuralNetwork({
    required NeuralNetwork nn,
    List<InputAndExpectedOutput>? trainingData,
  })  : _nn = nn,
        _trainingData = trainingData ?? [];

  set trainingData(List<InputAndExpectedOutput> trainingData) {
    _trainingData = trainingData;
    _currentTrainingDataIndex = trainingData.isEmpty ? -1 : 0;

    _nn.predict(trainingData.first.input);
  }

  InputAndExpectedOutput? get currentTrainingData =>
      _currentTrainingDataIndex == -1
          ? null
          : _trainingData[_currentTrainingDataIndex];

  bool get hasNextTrainingData =>
      _currentTrainingDataIndex < _trainingData.length - 1;

  bool get hasPreviousTrainingData => _currentTrainingDataIndex > 0;

  @override
  void addInputLayer(int neuronAmount,
          num Function(num acc, int counter)? activationFunction) =>
      _nn.addInputLayer(neuronAmount, activationFunction);

  @override
  void addLayer(int neuronAmount,
          num Function(num acc, int counter)? activationFunction,
          {String layerName = "", bool addBias = true}) =>
      _nn.addLayer(neuronAmount, activationFunction,
          layerName: layerName, addBias: addBias);

  @override
  void addOutputLayer(int neuronAmount,
          num Function(num acc, int counter)? activationFunction) =>
      _nn.addOutputLayer(neuronAmount, activationFunction);

  @override
  List<Layer> get layers => _nn.layers;

  @override
  List<num> predict(List<num> input) => _nn.predict(input);

  @override
  bool updateConnectionWeight(String connectionName, num newWeight) =>
      _nn.updateConnectionWeight(connectionName, newWeight);

  @override
  List<num> refresh() => _nn.refresh();

  @override
  List<num> get output => _nn.output;

  void nextTrainingData() {
    if (hasNextTrainingData) {
      _currentTrainingDataIndex++;
    }

    final inputAndExpectedOutput = currentTrainingData;
    if (inputAndExpectedOutput == null) {
      return;
    }

    final input = inputAndExpectedOutput.input;
    _nn.predict(input);
  }

  void previousTrainingData() {
    if (hasPreviousTrainingData) {
      _currentTrainingDataIndex--;
    }

    final inputAndExpectedOutput = currentTrainingData;
    if (inputAndExpectedOutput == null) {
      return;
    }

    final input = inputAndExpectedOutput.input;
    _nn.predict(input);
  }

  @override
  List<num> eval(List<num> input) => _nn.eval(input);
}
