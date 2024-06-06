import 'connection.dart';

class Neuron {
  num _value = 1;
  num _receiveForwardPropagationAcc = 0;
  int _receiveForwardPropagationCounter = 0;
  bool _isReceivingForwardPropagation = false;
  final bool isBias;
  final String _layerName;
  final String _neuronName;
  final num Function(num value, int counter) _activationFunction;
  final List<Connection> _connections = List.empty(growable: true);
  final List<Connection> _nextLayerConnections = List.empty(growable: true);
  final List<Connection> _previousLayerConnections = List.empty(growable: true);

  Neuron(num value, activationFunction,
      {this.isBias = false, layerName = "", neuronName = ""})
      : _value = value,
        _layerName = layerName,
        _neuronName = neuronName,
        _activationFunction = activationFunction;

  void addConnection(Connection connection) {
    assert(connection.isLowerLayerNeuron(this) ||
        connection.isUpperLayerNeuron(this));

    _connections.add(connection);
    if (connection.isLowerLayerNeuron(this)) {
      _nextLayerConnections.add(connection);
    } else {
      _previousLayerConnections.add(connection);
    }
  }

  void startReceivingForwardPropagation() {
    if (isBias) return;

    _isReceivingForwardPropagation = true;
  }

  void endReceivingForwardPropagation() {
    if (isBias) return;

    _isReceivingForwardPropagation = false;
    _value = _activationFunction(
        _receiveForwardPropagationAcc, _receiveForwardPropagationCounter);
    _receiveForwardPropagationAcc = 0;
    _receiveForwardPropagationCounter = 0;

    print(
        "El valor al final de la propagación en la neurona $fullName es: $_value");
  }

  void receiveForwardPropagation(num value) {
    if (isBias) return;

    _receiveForwardPropagationCounter++;
    _receiveForwardPropagationAcc += value;
  }

  void propagate() {
    assert(!_isReceivingForwardPropagation);
    print(
        "Propagando en la neurona $fullName con valor $_value. La cantidad de conexiones es: ${_nextLayerConnections.length}");
    for (var connection in _nextLayerConnections) {
      connection.propagate(_value);
    }
  }

  set value(num value) => _value = value;

  num get value => _value;

  String get layerName => _layerName;

  List<Connection> get connections => List.unmodifiable(_connections);

  operator [](int index) => _nextLayerConnections[index];

  get fullName => ('L:' + _layerName + ' N:' + _neuronName).trim();

  get nameInsideLayer => (_neuronName).trim();

  @override
  String toString() {
    return 'Neuron {'
        '_layerName: $_layerName, '
        '_neuronName: $_neuronName, '
        '_value: $_value, '
        '_isReceivingForwardPropagation: $_isReceivingForwardPropagation, '
        '_receiveForwardPropagationAcc: $_receiveForwardPropagationAcc, '
        '_receiveForwardPropagationCounter: $_receiveForwardPropagationCounter, '
        '_nextLayerConnections: $_nextLayerConnections'
        '}';
  }
}
