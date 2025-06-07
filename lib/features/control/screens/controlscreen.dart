import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panther/data/services/socket/socket_service.dart';
import '../widgets/servo.dart';
import '../widgets/alarm.dart';
import '../widgets/battery.dart';
import '../widgets/joystick.dart';

class Controlscreen extends StatefulWidget {
  const Controlscreen({super.key});

  @override
  State<Controlscreen> createState() => _ControlscreenState();
}

class _ControlscreenState extends State<Controlscreen> {
  final SocketService _socketService = SocketService();
  late StreamSubscription<Map<String, dynamic>> _messageSubscription;
  
  int batteryLevel = 0;
  bool isConnected = false;
  double speed = 5;
  Timer? _dataUpdateTimer;
  
  // RPi Stats
  int? armClock;
  double? cpuTemperature;
  double? coreVoltage;

@override
void initState() {
  super.initState();
  
  // Check if we're actually connected
  if (!_socketService.isConnected) {
    print('WARNING: Not connected to server when opening control screen!');
    // Navigate back to connection screen after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/');
    });
    return;
  }
  
  // Subscribe to messages
  _messageSubscription = _socketService.messageStream.listen((data) {
    print('Received data: $data');
    
    if (data['type'] == 'stats' && data['content'] != null) {
      _handleStringResponse(data['content']);
    } else if (data['type'] == 'message' && data['content'] != null) {
      _handleStringResponse(data['content']);
    } else if (data['type'] == 'status') {
      _handleStatusData(data);
    } else if (data['type'] == 'connectionClosed') {
      // Handle connection closed
      if (mounted) {
        setState(() => isConnected = false);
        _handleConnectionError();
      }
    }
  }, onError: (error) {
    print('Stream error: $error');
    if (!mounted) return;
    _handleConnectionError();
  }, onDone: () {
    print('Stream closed');
    if (!mounted) return;
    setState(() => isConnected = false);
    _handleConnectionError();
  });
  
  _startDataUpdates();
  setState(() {
    isConnected = _socketService.isConnected;
  });
}

  

 

  void _handleStatusData(Map<String, dynamic> data) {
    // Handle status updates if needed
    if (data['battery'] != null) {
      setState(() {
        batteryLevel = data['battery'];
      });
    }
  }
  
  void _handleStringResponse(String response) {
    // Check if this is a stats response
    if (response.contains('CLOCK:') && response.contains('TEMP:') && response.contains('VOLT:')) {
      _parseStatsResponse(response);
    } else if (response.contains('Login successful')) {
      setState(() => isConnected = true);
    } else if (response.contains('Disconnected')) {
      setState(() => isConnected = false);
    } else if (response.startsWith('move ')) {
      // Movement acknowledged
      print('Movement acknowledged: $response');
    } else if (response.contains('Invalid command')) {
      _showSnackBar('Invalid command');
    }
  }

  void _parseStatsResponse(String statsData) {
    // Parse format: "CLOCK:1500000000|TEMP:45.5|VOLT:1.35"
    try {
      final parts = statsData.split('|');
      
      for (final part in parts) {
        if (part.startsWith('CLOCK:')) {
          final clockStr = part.substring(6);
          armClock = int.tryParse(clockStr);
        } else if (part.startsWith('TEMP:')) {
          final tempStr = part.substring(5);
          cpuTemperature = double.tryParse(tempStr);
        } else if (part.startsWith('VOLT:')) {
          final voltStr = part.substring(5);
          coreVoltage = double.tryParse(voltStr);
        }
      }
      
      // Update battery level based on temperature
      if (cpuTemperature != null) {
        setState(() {
          batteryLevel = _calculateBatteryLevel(cpuTemperature!);
        });
      }
      
      print('Stats updated - Clock: $armClock Hz, Temp: $cpuTemperature°C, Voltage: $coreVoltage V');
      
    } catch (e) {
      print('Error parsing stats response: $e');
    }
  }

  int _calculateBatteryLevel(double temperature) {
    // Simulate battery based on temperature
    if (temperature < 40) return 100;
    if (temperature < 45) return 90;
    if (temperature < 50) return 80;
    if (temperature < 55) return 70;
    if (temperature < 60) return 60;
    if (temperature < 65) return 50;
    if (temperature < 70) return 40;
    if (temperature < 75) return 30;
    return 20;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startDataUpdates() {
    // Request data updates every 5 seconds
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_socketService.isConnected) {
        _socketService.sendMessage('info');
      }
    });

    // Initial request after a short delay to ensure connection
    Future.delayed(const Duration(seconds: 1), () {
      if (_socketService.isConnected) {
       _socketService.sendMessage('info');
      }
    });
  }
  
 bool _errorDialogShown = false;

void _handleConnectionError() {
  if (_errorDialogShown) return;
  _errorDialogShown = true;
  
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
          onPressed: () {
            Navigator.pop(context);
            _errorDialogShown = false;
          },
          child: const Text('No'),
        ),
      ],
    ),
  ).then((_) {
    _errorDialogShown = false;
  });
}

  // Replace all the JSON command methods with simple string commands

void _sendJoystickCommand(double x, double y) {
  if (_socketService.isConnected) {
    const double threshold = 0.3;
    String direction;
    
    if (y < -threshold) {
      // Forward movements
      if (x > threshold) {
        direction = 'forward-right';
      } else if (x < -threshold) {
        direction = 'forward-left';
      } else {
        direction = 'forward';
      }
    } else if (y > threshold) {
      // Backward movements
      if (x > threshold) {
        direction = 'back-right';
      } else if (x < -threshold) {
        direction = 'back-left';
      } else {
        direction = 'backward';
      }
    } else {
      // Pure horizontal or no movement
      if (x > threshold) {
        direction = 'right';
      } else if (x < -threshold) {
        direction = 'left';
      } else {
        // Don't send stop continuously
        return;
      }
    }
    
    // Send simple string command
    _socketService.sendMessage(direction);
  }
}

void _sendSpeedCommand(double newSpeed) {
  if (_socketService.isConnected) {
    setState(() => speed = newSpeed);
    // Server doesn't seem to handle speed commands, so just update local state
    // If server supports it, send: _socketService.sendMessage('speed ${newSpeed.round()}');
  }
}

void _sendCameraOpenCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('open-camera');
  }
}

void _sendCameraCloseCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('close-camera');
  }
}

void _sendCaptureCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('capture');
  }
}

void _sendAlarmCommand() {
  if (_socketService.isConnected) {
    // Server doesn't seem to have alarm command in the code you showed
    // If it does, use the appropriate command string
    _socketService.sendMessage('alarm');
  }
}

void _sendServoUpCommand() {
  if (_socketService.isConnected) {
    // Server doesn't show servo commands, but if supported:
    _socketService.sendMessage('servo-up');
  }
}

void _sendServoDownCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('servo-down');
  }
}

void _sendServoLeftCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('servo-left');
  }
}

void _sendServoRightCommand() {
  if (_socketService.isConnected) {
    _socketService.sendMessage('servo-right');
  }
}

@override
void dispose() {
  _dataUpdateTimer?.cancel();
  _messageSubscription.cancel();
  
  // Send exit command before disconnecting
  if (_socketService.isConnected) {
    try {
      _socketService.sendMessage('exit');
      // Give server time to process exit command
      Future.delayed(const Duration(milliseconds: 100), () {
        _socketService.disconnect();
      });
    } catch (e) {
      print('Error sending exit command: $e');
      _socketService.disconnect();
    }
  }
  
  super.dispose();
}

  // Helper method to get temperature color
  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 40) return Colors.green;
    if (temp < 50) return Colors.lightGreen;
    if (temp < 60) return Colors.yellow;
    if (temp < 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatWidget(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (orientation != Orientation.landscape)
              Center(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.screen_rotation,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Please rotate your phone",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
    onStickDragEnd: () {
      // Send stop command when joystick is released
      if (_socketService.isConnected) {
        _socketService.sendMessage('stop');
      }
    },
  ),
),
              
              // Top left - Battery and connection status
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    BatteryIndicator(batteryLevel: batteryLevel),
                    const SizedBox(width: 20),
                    const SizedBox(width: 20),
                    // Camera controls
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.black.withOpacity(0.6),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       IconButton(
                    //         icon: Icon(Icons.camera_alt, color: Colors.white),
                    //         onPressed: _sendCameraOpenCommand,
                    //         tooltip: 'Open Camera',
                    //       ),
                    //       IconButton(
                    //         icon: Icon(Icons.no_photography, color: Colors.white),
                    //         onPressed: _sendCameraCloseCommand,
                    //         tooltip: 'Close Camera',
                    //       ),
                    //       IconButton(
                    //         icon: Icon(Icons.photo_camera, color: Colors.white),
                    //         onPressed: _sendCaptureCommand,
                    //         tooltip: 'Capture Photo',
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              
              // Top center - RPi Stats display
              Positioned(
                top: 20,
                left: screenSize.width * 0.35,
                right: screenSize.width * 0.35,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RASPBERRY PI STATUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // CPU Temperature
                          _buildStatWidget(
                            Icons.thermostat,
                            'CPU TEMP',
                            cpuTemperature != null 
                              ? '${cpuTemperature!.toStringAsFixed(1)}°C'
                              : '--.-°C',
                            _getTemperatureColor(cpuTemperature),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          // ARM Clock
                          _buildStatWidget(
                            Icons.speed,
                            'ARM CLOCK',
                            armClock != null 
                              ? '${(armClock! / 1000000).toStringAsFixed(0)} MHz'
                              : '-- MHz',
                            Colors.blue,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          // Core Voltage
                          _buildStatWidget(
                            Icons.bolt,
                            'CORE VOLT',
                            coreVoltage != null 
                              ? '${coreVoltage!.toStringAsFixed(2)}V'
                              : '--.--V',
                            Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Top right - Alarm button and speed control
           Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                // Camera capture button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _sendCaptureCommand,
                    tooltip: 'Capture Photo',
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 15),
                AlarmButton(
                  onPressed: _sendAlarmCommand,
                ),
              ],
            ),
          ),
              
              // Bottom left - Speed meter
              // Positioned(
              //   bottom: 35,
              //   left: 200,
              //   child: Container(
              //     width: 120,
              //     height: 120,
              //     decoration: BoxDecoration(
              //       color: Colors.black.withOpacity(0.6),
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: Colors.white.withOpacity(0.2),
              //         width: 2,
              //       ),
              //     ),
              //     child: Center(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(
              //             Icons.speed,
              //             color: Colors.white,
              //             size: 30,
              //           ),
              //           const SizedBox(height: 8),
              //           Text(
              //             '${speed.toInt()}',
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 32,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           Text(
              //             'SPEED',
              //             style: TextStyle(
              //               color: Colors.white70,
              //               fontSize: 12,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              
              // Right side - Servo control
              Positioned(
                right: 20,
                top: screenSize.height * 0.35,
                child: ServoControl(
                  onUp: _sendServoUpCommand,
                  onDown: _sendServoDownCommand,
                  onLeft: _sendServoLeftCommand,
                  onRight: _sendServoRightCommand,
                ),
              ),
              
              // Bottom center - Info display
              // Positioned(
              //   bottom: 20,
              //   left: screenSize.width * 0.4,
              //   right: screenSize.width * 0.4,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //     decoration: BoxDecoration(
              //       color: Colors.black.withOpacity(0.6),
              //       borderRadius: BorderRadius.circular(20),
              //       border: Border.all(
              //         color: Colors.white.withOpacity(0.2),
              //         width: 1,
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.info_outline,
              //           color: Colors.white70,
              //           size: 16,
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           'PANTHER ROBOT CONTROL',
              //           style: TextStyle(
              //             color: Colors.white70,
              //             fontSize: 12,
              //             fontWeight: FontWeight.w500,
              //             letterSpacing: 1.0,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              
              // Connection status overlay
              if (!isConnected)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connection Lost',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attempting to reconnect...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}