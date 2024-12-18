import 'package:flutter/material.dart';
import 'package:panther/Theme/colors.dart';

import '../../connection/blutooth.dart';
import '../widgets/alarm.dart';
import '../widgets/battery.dart';
import '../widgets/connection.dart';
import '../widgets/joystick.dart';
import '../widgets/speedmeter.dart';

class Controlscreen extends StatefulWidget {
  const Controlscreen({super.key});

  @override
  State<Controlscreen> createState() => _ControlscreenState();
}

class _ControlscreenState extends State<Controlscreen> {
  final int batteryLevel = 56;

  final bool isConnected = true;

  double speed = 5;

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Stack(
        children: [
          if (orientation != Orientation.landscape)

            Center(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: const Text(
                  "Please flip your phone",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (orientation == Orientation.landscape) ...[
            const Positioned(
              bottom: 35,
              left: 20,
              child: CustomJoystick(),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: BatteryIndicator(batteryLevel: batteryLevel),
            ),
            Positioned(
              top: 20,
              left: 90,
              child: ConnectionStatus(isConnected: isConnected),
            ),
            Positioned(
              bottom: 50,
              right: 40,
              child: Speedometer(speed: speed),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: AlarmButton(
                onPressed: () {
                  
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 35,
              child: SizedBox(
                width: 200,
                child: Slider(
                  activeColor: Appcolors.primary,
                  value: speed,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (double value) {
                    setState(() {
                      speed = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

