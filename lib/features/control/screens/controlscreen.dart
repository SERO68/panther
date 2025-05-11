import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:panther/core/theme/colors.dart';
import 'package:panther/data/services/socket/socket_service.dart';
import '../widgets/servo.dart';
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
    _socketService.messageStream.listen((message) {
      if (message.containsKey('type')) {
        if (message['type'] == 'batteryUpdate') {
          setState(() {
            batteryLevel = message['level'] ?? 0;
          });
        } else if (message['type'] == 'connectionStatus') {
          setState(() {
            isConnected = message['connected'] ?? false;
          });
        }
      }
    });
  }

  void _startDataUpdates() {
    // Request data updates every 5 seconds
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _socketService.sendMessage(jsonEncode({'type': 'getBatteryLevel'}));
      _socketService.sendMessage(jsonEncode({'type': 'getConnectionStatus'}));
    });

    // Initial request
    _socketService.sendMessage(jsonEncode({'type': 'getBatteryLevel'}));
    _socketService.sendMessage(jsonEncode({'type': 'getConnectionStatus'}));
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top bar with battery and connection status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      ConnectionStatus(isConnected: isConnected),
                      const SizedBox(width: 16),
                      BatteryIndicator(batteryLevel: batteryLevel),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Main control area
              Expanded(
                child: Row(
                  children: [
                    // Left side - Joystick
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomJoystick(
                            onDirectionChanged: (double x, double y) {
                              // Send movement commands
                              _socketService.sendMessage(jsonEncode({
                                'type': 'moveCommand',
                                'direction': {'x': x, 'y': y}
                              }));
                            },
                          ),
                        ],
                      ),
                    ),
                    // Right side - Speed and other controls
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Speed meter
                          Speedometer(
                            speed: speed,
                            onSpeedChanged: (newSpeed) {
                              setState(() {
                                speed = newSpeed;
                              });
                              _socketService.sendMessage(jsonEncode({
                                'type': 'speedCommand',
                                'speed': newSpeed,
                              }));
                            },
                          ),
                          // Servo controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ServoControl(
                                onUp: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'arm',
                                    'direction': 'up'
                                  }));
                                },
                                onDown: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'arm',
                                    'direction': 'down'
                                  }));
                                },
                                onLeft: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'arm',
                                    'direction': 'left'
                                  }));
                                },
                                onRight: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'arm',
                                    'direction': 'right'
                                  }));
                                },
                              ),
                              ServoControl(
                                onUp: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'gripper',
                                    'direction': 'up'
                                  }));
                                },
                                onDown: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'gripper',
                                    'direction': 'down'
                                  }));
                                },
                                onLeft: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'gripper',
                                    'direction': 'left'
                                  }));
                                },
                                onRight: () {
                                  _socketService.sendMessage(jsonEncode({
                                    'type': 'servoCommand',
                                    'servo': 'gripper',
                                    'direction': 'right'
                                  }));
                                },
                              ),
                            ],
                          ),
                          // Alarm button
                          AlarmButton(
                            onPressed: () {
                              _socketService.sendMessage(jsonEncode({
                                'type': 'alarmCommand',
                                'action': 'toggle',
                              }));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}