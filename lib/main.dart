import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:untitled/input_and_expected_output.dart';
import 'package:untitled/manual_neural_network.dart';
import 'package:untitled/platform_extension.dart';

import 'combine_latest.dart';
import 'connection_weight_slider.dart';
import 'graphic_neural_network.dart';
import 'neural_network.dart';
import 'neural_network_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Edge? currentEdge;
  late final ManualNeuralNetwork manualNN;
  late final GraphicNeuralNetwork gnn;

  StreamController<Edge?> currentConnectionStreamController =
      StreamController();
  StreamController<InputAndExpectedOutput?>
      currentInputAndExpectedOutputStreamController = StreamController();
  StreamController<List<num>> currentOutputStreamController =
      StreamController();

  late final Stream<Edge?> currentConnectionStream =
      currentConnectionStreamController.stream.asBroadcastStream();
  late final Stream<InputAndExpectedOutput?>
      currentInputAndExpectedOutputStream =
      currentInputAndExpectedOutputStreamController.stream.asBroadcastStream();
  late final Stream<List<num>> currentOutputStream =
      currentOutputStreamController.stream.asBroadcastStream();

  late final Stream<num> distanceStream = CombineLatest(
    currentInputAndExpectedOutputStream
        .where((InputAndExpectedOutput? element) => element != null)
        .map(
          (InputAndExpectedOutput? element) => element!.expectedOutput,
        ),
    currentOutputStream,
    (List<num> expectedOutput, List<num> currentOutput) => sqrt(
      expectedOutput.indexed.fold(
        0,
        (num previousValue, (int, num) element) =>
            previousValue +
            pow(
              (element.$2 - currentOutput[element.$1]),
              2,
            ),
      ),
    ),
  );

  _MyHomePageState() {
    currentConnectionStream.listen((Edge? edge) {
      currentEdge = edge;
    });
  }

  @override
  void initState() {
    super.initState();

    final NeuralNetwork nn = NeuralNetwork();
    nn.addInputLayer(1, (acc, counter) => acc);
    nn.addLayer(2, (acc, counter) => acc, layerName: "1");
    nn.addOutputLayer(1, (acc, counter) => acc);

    final inputLayer = nn.layers.first;
    final inputNeuron = inputLayer[0];

    inputNeuron[0].weight = 0.5;
    inputNeuron[1].weight = 5;

    manualNN = ManualNeuralNetwork(nn: nn);

    manualNN.trainingData = [
      InputAndExpectedOutput([10], [120]),
    ];

    manualNN.refresh();
    currentInputAndExpectedOutputStreamController
        .add(manualNN.currentTrainingData);

    gnn = GraphicNeuralNetwork(manualNN);
  }

  Color _calculateErrorColor(num value) {
    if (value == 0) {
      return Colors.green;
    } else {
      return Color.lerp(Colors.red, Colors.green, (100 - value) / 100)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: StreamBuilder<num>(
                  stream: distanceStream,
                  builder: (context, AsyncSnapshot<num> snapshot) {
                    return Container(
                      color: _calculateErrorColor(snapshot.data ?? 100),
                      child: Center(
                        child: Text(
                          "Target: ${manualNN.currentTrainingData?.expectedOutput.fold("", (previousValue, element) => previousValue + element.toStringAsFixed(2) + ", ")}"
                          "\n"
                          "Prediction: ${manualNN.output.fold("", (previousValue, element) => previousValue + element.toStringAsFixed(2) + ", ")}"
                          "\n"
                          "Distance: ${snapshot.data?.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: snapshot.data == 0 ? 25 : 20,
                            fontWeight: snapshot.data == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Flexible(
              flex: 9,
              child: NeuralNetworkWidget(
                  nn: gnn,
                  setEdge: (Edge? edge) {
                    currentConnectionStreamController.sink.add(edge);
                  },
                  setValue: (double value) {
                    final innerCurrentEdge = currentEdge;
                    if (innerCurrentEdge == null) {
                      return;
                    }

                    gnn.setConnectionWeightByName(
                      innerCurrentEdge.data["edgeName"],
                      value,
                    );

                    currentOutputStreamController.sink.add(manualNN.output);
                  }),
            ),
            if (isMobile)
              StreamBuilder<Edge?>(
                stream: currentConnectionStream,
                builder: (BuildContext context, AsyncSnapshot<Edge?> snapshot) {
                  final Edge? edge = snapshot.data;
                  final double? weight = edge?.data['weight'].toDouble();
                  return Flexible(
                    flex: 1,
                    child: edge != null && weight != null
                        ? ConnectionWeightSlider(
                            showTitle: true,
                            edge,
                            (value) {
                              gnn.setConnectionWeightByName(
                                  edge.data["edgeName"], value);
                              currentConnectionStreamController.sink.add(edge);
                            },
                          )
                        : const Text("Select a connection"),
                  );
                },
              )
          ],
        ),
      ),
    ));
  }
}
