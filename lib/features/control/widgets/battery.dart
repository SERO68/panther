import 'package:flutter/material.dart';

class BatteryIndicator extends StatelessWidget {
  final int batteryLevel;

  const BatteryIndicator({super.key, required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.battery_full,
          color: batteryLevel > 20 ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 5),
        Text('$batteryLevel%'),
      ],
    );
  }
}