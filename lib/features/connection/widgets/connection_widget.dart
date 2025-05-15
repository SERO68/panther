import 'package:flutter/material.dart';
import 'package:panther/data/services/socket/socket_service.dart';

class ConnectionWidget extends StatelessWidget {
  final SocketService socketService;
  
  const ConnectionWidget({super.key, required this.socketService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Connection Status: ${socketService.isConnected ? "Connected" : "Disconnected"}',
            style: TextStyle(
              color: socketService.isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}