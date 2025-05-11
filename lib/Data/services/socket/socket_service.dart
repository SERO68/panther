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

  Future<void> connect([String? ip]) async {
    if (_socket != null) return;
    
    // If no IP is provided but we have a stored server IP, use that
    final serverIP = ip ?? _serverIP;
    if (serverIP == null) {
      print('Cannot connect: No IP address provided');
      _messageController.add({
        'type': 'connectionError',
        'message': 'No IP address provided'
      });
      return;
    }

    try {
      print('Connecting to $serverIP:8080');
      _socket = await Socket.connect(serverIP, 8080);
      _serverIP = serverIP;
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
      // Try to parse as JSON
      final jsonData = json.decode(response);
      _messageController.add(jsonData);
    } catch (e) {
      print('Error parsing response: $e');
      // If not valid JSON, send as a simple message
      _messageController.add({
        'type': 'message',
        'content': response,
      });
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.destroy();
      _socket = null;
      _serverIP = null;
      print('Disconnected from server');
    }
  }

  void sendMessage(dynamic message) {
    if (_socket != null) {
      String messageStr;
      if (message is Map) {
        messageStr = json.encode(message);
      } else {
        messageStr = message.toString();
      }
      print('Sending: $messageStr');
      _socket!.write(messageStr);
    } else {
      print('Cannot send message: not connected');
      throw Exception('Not connected to server');
    }
  }

  void sendCommand(String command, [Map<String, dynamic>? params]) {
    final message = {
      'command': command,
      if (params != null) ...params,
    };
    sendMessage(json.encode(message));
  }

  void login(String username, String password) {
    sendCommand('login', {
      'username': username,
      'password': password,
    });
  }

  void moveRobot(double x, double y) {
    sendCommand('move', {
      'x': x,
      'y': y,
    });
  }

  void stopRobot() {
    sendCommand('stop');
  }

  void setSpeed(double speed) {
    sendCommand('set_speed', {
      'speed': speed,
    });
  }

  void toggleLight() {
    sendCommand('toggle_light');
  }

  void toggleAlarm() {
    sendCommand('toggle_alarm');
  }

  void requestStatus() {
    sendCommand('get_status');
  }

  void requestShifts() {
    sendCommand('get_shifts');
  }

  void setServoPosition(int servoId, double position) {
    sendCommand('set_servo', {
      'servo_id': servoId,
      'position': position,
    });
  }

  void scanWifi() {
    sendCommand('scan_wifi');
  }

  void connectToWifi(String ssid, String password) {
    sendCommand('connect_wifi', {
      'ssid': ssid,
      'password': password,
    });
  }

  void requestBatteryLevel() {
    sendCommand('get_battery');
  }

  void requestConnectionStatus() {
    sendCommand('get_connection_status');
  }
}