import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:panther/data/services/socket/socket_service.dart';

class MockSocketService implements SocketService {
  bool _isConnected = false;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  @override
  bool get isConnected => _isConnected;
  
  @override
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  @override
  Future<void> connect([String? ip]) async {
    _isConnected = true;
  }
  
  @override
  void disconnect() {
    _isConnected = false;
  }
  
  @override
  void sendMessage(dynamic message) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void sendCommand(String command, [Map<String, dynamic>? params]) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void login(String username, String password) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void moveRobot(double x, double y) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void stopRobot() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void setSpeed(double speed) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void toggleLight() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void toggleAlarm() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void requestStatus() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void requestShifts() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void setServoPosition(int servoId, double position) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void scanWifi() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void connectToWifi(String ssid, String password) {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void requestBatteryLevel() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  @override
  void requestConnectionStatus() {
    if (!_isConnected) {
      throw Exception('Not connected to server');
    }
  }
  
  void addMessage(Map<String, dynamic> message) {
    _messageController.add(message);
  }
  
  void dispose() {
    _messageController.close();
  }
}

void main() {
  group('SocketService Tests', () {
    late MockSocketService mockSocketService;
    
    setUp(() {
      mockSocketService = MockSocketService();
    });
    
    tearDown(() {
      mockSocketService.dispose();
    });
    
    test('isConnected should return false initially', () {
      expect(mockSocketService.isConnected, false);
    });
    
    test('connect should handle successful connection', () async {
      await mockSocketService.connect('192.168.1.1');
      
      expect(mockSocketService.isConnected, true);
    });
    
    test('messageStream should emit messages', () async {
      final testMessage = {'type': 'test', 'message': 'Hello'};
      
      expectLater(mockSocketService.messageStream, emits(testMessage));
      mockSocketService.addMessage(testMessage);
    });
    
    test('sendMessage should throw exception when not connected', () {
      expect(() => mockSocketService.sendMessage({'command': 'test'}), throwsException);
    });
  });
}