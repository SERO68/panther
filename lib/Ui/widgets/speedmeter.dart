import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Speedometer extends StatelessWidget {
  final double speed;

  const Speedometer({super.key, required this.speed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100, 
            ranges: <GaugeRange>[
              GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
              GaugeRange(startValue: 30, endValue: 60, color: Colors.orange),
              GaugeRange(startValue: 60, endValue: 100, color: Colors.red),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(value: speed),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '${speed.toStringAsFixed(1)} m/h',  
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
