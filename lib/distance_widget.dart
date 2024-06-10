import 'package:flutter/material.dart';

import 'manual_neural_network.dart';

class DistanceWidget extends StatelessWidget {
  final Stream<num> distanceStream;
  final ManualNeuralNetwork manualNN;
  final Function() nextClickListener;
  final Function() previousClickListener;

  const DistanceWidget(
      {super.key,
      required this.distanceStream,
      required this.manualNN,
      required this.nextClickListener,
      required this.previousClickListener});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<num>(
      stream: distanceStream,
      builder: (context, AsyncSnapshot<num> snapshot) => Container(
        color: _calculateErrorColor(snapshot.data ?? 100),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Container(color: Colors.blueAccent),
            ),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
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
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: manualNN.hasPreviousTrainingData
                                ? previousClickListener
                                : null,
                            child: Text(
                              "Previous",
                              style: TextStyle(color: Colors.white),
                            )),
                        TextButton(
                          onPressed: manualNN.hasNextTrainingData
                              ? nextClickListener
                              : null,
                          child: Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _calculateErrorColor(num value) {
    if (value == 0) {
      return Colors.green;
    } else {
      return Color.lerp(Colors.red, Colors.green, (100 - value) / 100)!;
    }
  }
}
