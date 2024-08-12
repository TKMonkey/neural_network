import 'dart:math';

import 'neuron.dart';

class Connection {
  final Neuron _lowerLayer;
  final Neuron _upperLayer;
  num weight = 0;

  Connection(this._lowerLayer, this._upperLayer, int? seed,
      [num? initialWeight]) {
    weight = _getRandomWeight(seed);
  }

  bool isLowerLayerNeuron(Neuron neuron) => _lowerLayer == neuron;

  bool isUpperLayerNeuron(Neuron neuron) => _upperLayer == neuron;

  void propagate(num value) {
    _upperLayer.receiveForwardPropagation(value * weight);
  }

  num _getRandomWeight(int? seed) => (Random().nextDouble() * 2 - 1) * 0.3;

  String get name => '${_lowerLayer.fullName}-${_upperLayer.fullName}';

  String get lowerLayerNeuronName => _lowerLayer.fullName;

  String get upperLayerNeuronName => _upperLayer.fullName;

  @override
  String toString() {
    return 'Connection { lowerLayerNeuron: ${_lowerLayer.fullName}, lowerLayerValue: ${_lowerLayer.value}, upperLayerNeuron: ${_upperLayer.fullName}, upperLayerValue: ${_upperLayer.value} weight: $weight }';
  }
}
