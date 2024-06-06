import 'connection.dart';
import 'neuron.dart';

class Layer {
  int? _seed;
  bool addBias;
  Layer? _nextLayer;
  String _layerName = "";
  Map<String, Connection> _connections = Map();
  List<Neuron> _neurons = List.empty(growable: false);

  Layer(
    int neuronQuantity,
    int? seed, {
    layerName = "",
    this.addBias = true,
  })  : _seed = seed,
        _layerName = layerName {
    _initializeNeurons(neuronQuantity);
  }

  Layer.withNextLayer(int neuronQuantity, Layer nextLayer, int? seed,
      {layerName = "", this.addBias = true})
      : _seed = seed,
        _layerName = layerName,
        _nextLayer = nextLayer {
    _initializeNeurons(neuronQuantity);

    _initializeConnections();
  }

  int get length => _neurons.length;

  operator [](int index) => _neurons[index];

  set values(List<num> values) {
    assert(values.length == length);

    for (int i = 0; i < values.length; i++) {
      _neurons[i].value = values[i];
    }
  }

  void addNextLayer(Layer layer) {
    _nextLayer = layer;
    _initializeConnections();
  }

  void propagate() {
    _nextLayer?._neurons.forEach((neuron) {
      neuron.startReceivingForwardPropagation();
    });

    for (var neuron in _neurons) {
      neuron.propagate();
    }

    _nextLayer?._neurons.forEach((neuron) {
      neuron.endReceivingForwardPropagation();
    });
  }

  num _activationFunction(num value, int acc) => value;

  void _initializeNeurons(int neuronQuantity) {
    final maxNeurons = neuronQuantity + (addBias ? 1 : 0);
    final List<Neuron> neurons = List.generate(
      maxNeurons,
      (index) {
        final isBiasNeuron = addBias && maxNeurons == index + 1;
        final name = isBiasNeuron ? "Bias" : "${index + 1}";

        return Neuron(
          1,
          _activationFunction,
          neuronName: name,
          isBias: isBiasNeuron,
          layerName: _layerName,
        );
      },
    );

    _neurons = neurons;
  }

  void _initializeConnections() {
    for (var myNeuron in _neurons) {
      _nextLayer?._neurons
          .where((element) => !element.isBias)
          .forEach((nextLayerNonBiasNeuron) {
        final newConnection =
            Connection(myNeuron, nextLayerNonBiasNeuron, _seed, 1);
        _connections[newConnection.name] = newConnection;
        myNeuron.addConnection(newConnection);
        nextLayerNonBiasNeuron.addConnection(newConnection);
      });
    }
  }

  List<num> get values => _neurons.map((neuron) => neuron.value).toList();

  Connection? getConnectionByName(String name) => _connections[name];
}
