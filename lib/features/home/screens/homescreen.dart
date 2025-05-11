import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panther/core/routes/approutes.dart';
import 'package:panther/data/services/socket/socket_service.dart';
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
    _setupSocketConnection();
  }

  void _setupSocketConnection() {
    _socketService.connect();
    _socketService.messageStream.listen((message) {
      if (message.containsKey('type')) {
        if (message['type'] == 'userData') {
          setState(() {
            _userName = message['data']['name'];
            _userId = message['data']['id'];
            _isLoading = false;
          });
        } else if (message['type'] == 'shiftsData') {
          setState(() {
            _shifts = List<Map<String, dynamic>>.from(message['data']['shifts']);
            _totalPaid = message['data']['totalPaid'].toString();
          });
        } else if (message['type'] == 'connectionError') {
          _scheduleReconnect();
        }
      }
    });

    // Request initial data
    _socketService.sendMessage({'type': 'getUserData'});
    _socketService.sendMessage({'type': 'getShifts'});
  }

  void _scheduleReconnect() {
    // Cancel any existing timer
    _reconnectTimer?.cancel();
    
    // Schedule reconnection attempt after 5 seconds
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _setupSocketConnection();
      }
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            // Navigate to settings
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Earnings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_totalPaid',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Shifts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // View all shifts
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _shifts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.work_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No shifts yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _shifts.length,
                              itemBuilder: (context, index) {
                                final shift = _shifts[index];
                                return ShiftCard(
                                  date: shift['date'] ?? 'Unknown date',
                                  hours: shift['hours']?.toString() ?? '0',
                                  amount: shift['amount']?.toString() ?? '0',
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Approutename.control);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Start New Shift',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}