import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panther/Routes/approutes.dart';
import '../../connection/wifi.dart';
import '../widgets/shiftcard.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  GlobalKey deletekey = GlobalKey();
  GlobalKey deletekey2 = GlobalKey();
  bool notifi1 = true;
  bool notifi2 = true;

  final SocketService _socketService = SocketService();
  String? _userName;
  String? _userId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _shifts = [];
  String _totalPaid = '0';
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    try {
      if (!_socketService.isConnected) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      _setupSocketListener();

      // Add timeout for entire connection process
      Timer(const Duration(seconds: 10), () {
        if (_isLoading) {
          _handleConnectionError();
        }
      });
    } catch (e) {
      print('Initialization error: $e');
      _handleConnectionError();
    }
  }

  void _setupSocketListener() {
    // Add timeout for initial data
    Timer(const Duration(seconds: 5), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _userName = "Guest User"; // Default value if no response
        });
      }
    });

    _socketService.messageStream.listen(
      (data) {
        print('Received data: $data'); // Debug print
        setState(() {
          switch (data['type']) {
            case 'user_data':
              _userName = data['name'];
              _userId = data['id'];
              _isLoading = false;
              break;
            case 'shifts_data':
              _shifts = List<Map<String, dynamic>>.from(data['shifts']);
              break;
            case 'payment_data':
              _totalPaid = data['total'];
              break;
            case 'message':
              print('Received message: ${data['content']}');
              // Set loading to false even for generic messages
              _isLoading = false;
              break;
          }
        });
      },
      onError: (error) {
        print('Stream error: $error');
        _handleConnectionError();
      },
      onDone: () {
        print('Stream closed');
        _handleConnectionError();
      },
    );

    // Request initial data
    _socketService.sendMessage('info');
  }

  void _handleConnectionError() {
    setState(() {
      _isLoading = false;
    });

    // Show error dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: const Text(
            'Lost connection to server. Return to connection screen?'),
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

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text('Connecting to server...'),
                    const SizedBox(height: 10),
                    Text(
                      _socketService.isConnected
                          ? 'Waiting for data...'
                          : 'Establishing connection...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  _socketService.sendMessage('info');
                  // Wait for response or timeout
                  return Future.delayed(const Duration(seconds: 5), () {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          AssetImage("images/blacklogo.png"),
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Welcome Mr",
                                            style: TextStyle(fontSize: 14)),
                                        Text(_userName ?? "Loading...",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, Approutename.control);
                                      },
                                      icon: const Icon(
                                        Icons.control_camera_rounded,
                                        color: Color(0xFF00ADDA),
                                        size: 30,
                                      ),
                                    ),
                                  
                                    IconButton(
                                      icon:
                                          const Icon(Icons.power_settings_new),
                                      color: Colors.red,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Disconnect Robot'),
                                            content: const Text(
                                                'Are you sure you want to disconnect?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _socketService.disconnect();
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/');
                                                },
                                                style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.red),
                                                child: const Text('Disconnect'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Connection Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _socketService.isConnected
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _socketService.isConnected
                                        ? Icons.wifi
                                        : Icons.wifi_off,
                                    color: _socketService.isConnected
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Connection: ${_socketService.isConnected ? "Active" : "Inactive"}',
                                    style: TextStyle(
                                      color: _socketService.isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Shifts Section
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Shifts",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_shifts.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No shifts available',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...List.generate(
                                _shifts.length,
                                (index) {
                                  final shift = _shifts[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Shiftcard(
                                      completed: shift['completed'] ?? false,
                                      checkin: shift['checkin'] ?? 'N/A',
                                      checkout: shift['checkout'] ?? 'N/A',
                                      name: shift['name'] ?? 'Unknown',
                                      payment: shift['payment'] ?? '0\$',
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Reports Section
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Reports",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                reportcard(
                                  icon: Icons.attach_money_outlined,
                                  number: '$_totalPaid\$',
                                  description: "Total paid",
                                ),
                              ],
                            ),
                            // Add some padding at the bottom for better scrolling
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class reportcard extends StatelessWidget {
  const reportcard({
    super.key,
    required this.icon,
    required this.number,
    required this.description,
  });

  final IconData icon;
  final String number;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: Card(
        color: const Color(0xFFF1F2F6),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
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
