import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  final bool isConnected;

  const ConnectionStatus({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 5),
        Text(isConnected ? 'Connected' : 'Disconnected'),
      ],
    );
  }
}
