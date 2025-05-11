import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panther/Theme/colors.dart';
import 'package:panther/Ui/widgets/servo.dart';
import '../../connection/wifi.dart';
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
  final SocketService _socketService = SocketService();
  int batteryLevel = 0;
  bool isConnected = false;
  double speed = 5;
  Timer? _dataUpdateTimer;

  @override
  void initState() {
    super.initState();
    _setupSocketListener();
    _startDataUpdates();
  }

  void _setupSocketListener() {
    _socketService.messageStream.listen(
      (data) {
        setState(() {
          switch (data['type']) {
            case 'robot_data':
              batteryLevel = data['battery'] ?? 0;
              speed = data['speed']?.toDouble() ?? 5.0;
              break;
            case 'connection_status':
              isConnected = data['connected'] ?? false;
              break;
          }
        });
      },
      onError: (error) {
        print('Stream error: $error');
        _handleConnectionError();
      },
    );
  }

void _startDataUpdates() {
  _dataUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_socketService.isConnected) {
      _socketService.getRobotStatus();
    }
  });
}
  void _handleConnectionError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: const Text(
            'Lost connection to robot. Return to connection screen?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

// In _ControlscreenState class

void _sendJoystickCommand(double x, double y) {
  if (_socketService.isConnected) {
    _socketService.sendJoystickCommand(x, y);
  }
}

void _sendSpeedCommand(double newSpeed) {
  if (_socketService.isConnected) {
    _socketService.setSpeed(newSpeed);
  }
}

void _sendCameraOpenCommand() {
  if (_socketService.isConnected) {
    _socketService.startStream();
  }
}

void _sendCameraCloseCommand() {
  if (_socketService.isConnected) {
    _socketService.stopStream();
  }
}

void _sendCaptureCommand() {
  if (_socketService.isConnected) {
    _socketService.captureImage();
  }
}

void _sendAlarmCommand() {
  if (_socketService.isConnected) {
    _socketService.sendAlert();
  }
}

void _sendServoUpCommand() {
  if (_socketService.isConnected) {
    _socketService.servoUp();
  }
}

void _sendServoDownCommand() {
  if (_socketService.isConnected) {
    _socketService.servoDown();
  }
}

void _sendServoLeftCommand() {
  if (_socketService.isConnected) {
    _socketService.servoLeft();
  }
}

void _sendServoRightCommand() {
  if (_socketService.isConnected) {
    _socketService.servoRight();
  }
}

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  var orientation = MediaQuery.of(context).orientation;
  final screenSize = MediaQuery.of(context).size;

  return Scaffold(
    body: SafeArea(
      child: Stack(
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
            // Left side - Joystick
            Positioned(
              bottom: 35,
              left: 20,
              child: CustomJoystick(
                onDirectionChanged: _sendJoystickCommand,
              ),
            ),
            
            // Top left - Battery and camera controls
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  BatteryIndicator(batteryLevel: batteryLevel),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _sendCameraOpenCommand,
                    icon: const Icon(Icons.videocam),
                    iconSize: 30,
                    color: Appcolors.primary,
                    tooltip: 'Open Camera',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _sendCameraCloseCommand,
                    icon: const Icon(Icons.videocam_off),
                    iconSize: 30,
                    color: Colors.red,
                    tooltip: 'Close Camera',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _sendCaptureCommand,
                    icon: const Icon(Icons.camera),
                    iconSize: 30,
                    color: Appcolors.primary,
                    tooltip: 'Capture Photo',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Top right - Alarm button and connection status
            Positioned(
              top: 20,
              right:  screenSize.width * 0.15- 80,
              child: Row(
                children: [
                  AlarmButton(
                    onPressed: _sendAlarmCommand,
                  ),
                ],
              ),
            ),
            
            // Center - Speed meter (smaller size)
            // Positioned(
            //   top: screenSize.height * 0.25, // Center vertically
            //   left: screenSize.width * 0.5 - 80, // Center horizontally with offset
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       // Reduced size speedometer
            //       Transform.scale(
            //         scale: 0.8, // Make speedometer smaller
            //         child: Speedometer(speed: speed),
            //       ),
            //       // Reduced width slider
            //       SizedBox(
            //         width: 200, // Smaller width
            //         height: 1,
            //         child: Slider(
            //           activeColor: Appcolors.primary,
            //           value: speed,
            //           min: 0,
            //           max: 100,
            //           divisions: 100,
            //           onChanged: (double value) {
            //             setState(() {
            //               speed = value;
            //             });
            //             _sendSpeedCommand(value);
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            
            // Right side - Servo control
            Positioned(
              right: 20,
              top: screenSize.height * 0.32, // Adjust vertical position
              child: ServoControl(
                onUp: _sendServoUpCommand,
                onDown: _sendServoDownCommand,
                onLeft: _sendServoLeftCommand,
                onRight: _sendServoRightCommand,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}
