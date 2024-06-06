import 'dart:math';

import 'neuron.dart';

class Connection {
  final Neuron _lowerLayer;
  final Neuron _upperLayer;
  num _weight = 0;

  Connection(this._lowerLayer, this._upperLayer, int? seed,
      [num? initialWeight]) {
    final weight =
        _lowerLayer.isBias ? 1 : initialWeight ?? _getRandomWeight(seed);
    _weight = weight;
  }

  bool isLowerLayerNeuron(Neuron neuron) => _lowerLayer == neuron;

  bool isUpperLayerNeuron(Neuron neuron) => _upperLayer == neuron;

  void propagate(num value) {
    _upperLayer.receiveForwardPropagation(value * _weight);
  }

  num _getRandomWeight(int? seed) {
    final int finalSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final random = Random(finalSeed);

    const maxNumber = 10000;
    return random.nextInt(maxNumber) / maxNumber;
  }

  set weight(num weight) {
    _weight = weight;
  }

  num get weight => _weight;

  String get name => '${_lowerLayer.fullName}-${_upperLayer.fullName}';

  String get lowerLayerNeuronName => _lowerLayer.fullName;

  String get upperLayerNeuronName => _upperLayer.fullName;

  @override
  String toString() {
    return 'Connection { lowerLayerNeuron: ${_lowerLayer.fullName}, lowerLayerValue: ${_lowerLayer.value}, upperLayerNeuron: ${_upperLayer.fullName}, upperLayerValue: ${_upperLayer.value} weight: $_weight }';
  }
}
