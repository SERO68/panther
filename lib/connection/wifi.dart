import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  String? _serverIP;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  bool get isConnected => _socket != null;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect(String ip) async {
    if (_socket != null) return;

    try {
      print('Connecting to $ip:8080');
      _socket = await Socket.connect(ip, 8080);
      _serverIP = ip;
      print('Connected successfully');

      _socket!.listen(
        (List<int> data) {
          final response = utf8.decode(data);
          print('Received: $response');
          _handleServerResponse(response);
        },
        onError: (error) {
          print('Socket error: $error');
          _messageController.addError(error);
          disconnect();
        },
        onDone: () {
          print('Socket closed');
          disconnect();
        },
      );
    } catch (e) {
      print('Connection error: $e');
      rethrow;
    }
  }

  void _handleServerResponse(String response) {
    try {
      print('Handling response: $response');
      
      // Process specific server responses based on the logs you provided
      if (response.contains("Received")) {
        _messageController.add({
          'type': 'message',
          'content': response,
          'status': 'received'
        });
      } else if (response.contains("Invalid password")) {
        _messageController.add({
          'type': 'message',
          'content': response,
          'status': 'error'
        });
      } else if (response.contains("Login successful")) {
        _messageController.add({
          'type': 'message',
          'content': response,
          'status': 'success'
        });
      } else {
        // For any other response, try parsing as JSON first
        try {
          final jsonData = json.decode(response);
          _messageController.add(jsonData);
        } catch (e) {
          // If not JSON, send as plain message
          _messageController.add({
            'type': 'message',
            'content': response,
            'status': 'unknown'
          });
        }
      }
    } catch (e) {
      print('Error handling response: $e');
      _messageController.addError(e);
    }
  }

  void sendMessage(String message) {
    if (_socket != null) {
      try {
        print('Sending message: $message');
        _socket!.write(message);
      } catch (e) {
        print('Error sending message: $e');
        _messageController.addError(e);
      }
    } else {
      print('Socket is null, cannot send message');
      _messageController.addError('Not connected to server');
    }
  }

  void _sendRobotCommand(String command) {
    if (_socket != null) {
      sendMessage(command);
    }
  }

  void sendJoystickCommand(double x, double y) {
    // Determine direction based on joystick coordinates
    // Convert the x,y coordinates to 8-directional movement
    
    // Threshold for determining diagonal movement
    const double threshold = 0.3;
    
    if (y < -threshold) {
      // Forward movements
      if (x > threshold) {
        _sendRobotCommand('forward-right');
      } else if (x < -threshold) {
        _sendRobotCommand('forward-left');
      } else {
        _sendRobotCommand('forward');
      }
    } else if (y > threshold) {
      // Backward movements
      if (x > threshold) {
        _sendRobotCommand('back-right');
      } else if (x < -threshold) {
        _sendRobotCommand('back-left');
      } else {
        _sendRobotCommand('backward');
      }
    } else {
      // Pure horizontal or no movement
      if (x > threshold) {
        _sendRobotCommand('right');
      } else if (x < -threshold) {
        _sendRobotCommand('left');
      } else {
        _sendRobotCommand('stop');
      }
    }
  }

  void setSpeed(double speed) {
    _sendRobotCommand('set speed ${speed.round()}');
  }

  void getRobotStatus() {
    _sendRobotCommand('info');
  }

  void startStream() {
    _sendRobotCommand('open-camera');
  }

  void stopStream() {
    _sendRobotCommand('close-camera');
  }

  void captureImage() {
    _sendRobotCommand('capture');
  }

  void sendAlert() {
    _sendRobotCommand('alert');
  }

  void servoUp() {
    _sendRobotCommand('servo-up');
  }

  void servoDown() {
    _sendRobotCommand('servo-down');
  }

  void servoLeft() {
    _sendRobotCommand('servo-left');
  }

  void servoRight() {
    _sendRobotCommand('servo-right');
  }

  void disconnect() {
    print('Disconnecting socket');
    if (_socket != null) {
      _sendRobotCommand('close');
      _socket?.destroy();
      _socket = null;
      _serverIP = null;
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}