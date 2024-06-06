import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'graphic_neural_network.dart';
import 'neuralnetwork.dart';
import 'nn_edge_line_shape.dart';
import 'nn_layout.dart';
import 'nn_vertex.dart';

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
  late final GraphicNeuralNetwork gnn;
  StreamController<Edge?> currentConnectionStream = StreamController();

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

    nn.predict([10]);

    gnn = GraphicNeuralNetwork(nn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Flexible(
              flex: 9,
              child: GraphNN(
                gnn,
                (Edge? edge) {
                  currentConnectionStream.sink.add(edge);
                },
              ),
            ),
            StreamBuilder<Edge?>(
                stream: currentConnectionStream.stream,
                builder: (BuildContext context, AsyncSnapshot<Edge?> snapshot) {
                  final Edge? edge = snapshot.data;
                  final double? weight = edge?.data['weight'].toDouble();
                  return Flexible(
                      flex: 1,
                      child: edge != null && weight != null
                          ? Column(
                              children: [
                                Text("Weight"),
                                Slider(
                                  value: weight,
                                  onChanged: (double value) {
                                    gnn.setConnectionWeightByName(
                                        edge.data["edgeName"], value);
                                    currentConnectionStream.sink
                                        .add(snapshot.data!);
                                  },
                                  min: -10,
                                  max: 10,
                                  divisions: 100,
                                  label: weight.toStringAsFixed(2),
                                ),
                              ],
                            )
                          : Text("Select a connection"));
                })
          ],
        ),
      ),
    ));
  }
}

class GraphNN extends StatelessWidget {
  final GraphicNeuralNetwork nn;
  final Function(Edge? edge)? setEdge;

  const GraphNN(this.nn, this.setEdge, {super.key});

  @override
  Widget build(BuildContext context) {
    final data = nn.data;

    return FlutterGraphWidget(
      data: data,
      algorithm: NNLayout(
        spaceBetweenLayers: 150,
        decorators: [],
      ),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..panelDelay = Duration.zero
        ..showText = true
        ..textGetter = (vertex) {
          return "";
        }
        ..graphStyle = (GraphStyle()
          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
          ..tagColor = {'tag8': Colors.orangeAccent.shade200}
          ..tagColorByIndex = [
            Colors.red.shade200,
            Colors.orange.shade200,
            Colors.yellow.shade200,
            Colors.green.shade200,
            Colors.blue.shade200,
            Colors.blueAccent.shade200,
            Colors.purple.shade200,
            Colors.pink.shade200,
            Colors.blueGrey.shade200,
            Colors.deepOrange.shade200,
          ])
        ..useLegend = true // default true
        ..edgePanelBuilder = edgePanelBuilder
        ..vertexPanelBuilder = vertexPanelBuilder
        ..edgeShape = NNEdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = NNVertex() // default is VertexCircleShape.
        ..backgroundBuilder =
            (BuildContext context) => Container(color: Colors.white),
    );
  }

  Widget edgePanelBuilder(Edge edge, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(edge.position);
    setEdge?.call(edge);

    return const SizedBox(
      width: 0,
      height: 0,
    );
  }

  Widget vertexPanelBuilder(hoverVertex, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(hoverVertex.cpn!.position);
    return Stack(
      children: [
        Positioned(
          left: c.x + hoverVertex.radius + 5,
          top: c.y - 20,
          child: SizedBox(
            width: 120,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                  "Value: ${hoverVertex.data["currentValue"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
