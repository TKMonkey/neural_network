import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ConnectionWeightSlider extends StatefulWidget {
  final Edge edge;
  final bool showTitle;
  final Function(double value)? onChanged;
  const ConnectionWeightSlider(this.edge, this.onChanged,
      {super.key, this.showTitle = false});

  @override
  State<ConnectionWeightSlider> createState() => _ConnectionWeightSliderState();
}

class _ConnectionWeightSliderState extends State<ConnectionWeightSlider> {
  late double internalWeight;

  @override
  void initState() {
    super.initState();
    internalWeight = widget.edge.data?['weight']?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (widget.showTitle) const Text("Weight"),
          Slider(
            value: internalWeight,
            onChanged: (value) {
              setState(() {
                internalWeight = value;
                widget.onChanged?.call(value);
              });
            },
            min: -1,
            max: 1,
            divisions: 100,
            label: widget.showTitle ? internalWeight.toStringAsFixed(2) : null,
          ),
        ],
      );
}
