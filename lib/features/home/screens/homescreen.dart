import 'package:flutter/material.dart';
import 'package:panther/core/routes/approutes.dart';
import '../widgets/shiftcard.dart';
import '../widgets/notificationcard.dart';

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

  // Fixed user data
  final String _userName = 'John Doe';
  final String _userId = '12345';
  bool _isLoading = true;
  
  // Fixed shifts data
  final List<Map<String, dynamic>> _shifts = [
    {
      'completed': true,
      'checkin': '09:00 AM',
      'checkout': '05:00 PM',
      'name': 'Morning Shift',
      'payment': '160\$'
    },
    {
      'completed': false,
      'checkin': '06:00 PM',
      'checkout': '12:00 AM',
      'name': 'Evening Shift',
      'payment': '120\$'
    },
    {
      'completed': true,
      'checkin': '08:00 AM',
      'checkout': '03:00 PM',
      'name': 'Day Shift',
      'payment': '140\$'
    }
  ];
  
  // Fixed total paid amount
  final String _totalPaid = '420';
  // Fixed connection status for UI display
  final bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
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
                    const Text('Loading data...'),
                    const SizedBox(height: 10),
                    Text(
                      'Please wait...',
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
                  // Simulate data refresh
                  return Future.delayed(const Duration(seconds: 1), () {
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
                                color: _isConnected
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isConnected
                                        ? Icons.wifi
                                        : Icons.wifi_off,
                                    color: _isConnected
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Connection: ${_isConnected ? "Active" : "Inactive"}',
                                    style: TextStyle(
                                      color: _isConnected
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
                            
                            // Notifications Section
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Fixed notification card
                            const NotificationCard(
                              title: "Unauthorized access at Entrance B",
                              message: "There is someone who trying to enter into the building",
                              timestamp: "10:22 PM",
                              icon: Icons.warning,
                              iconColor: Colors.red,
                              borderColor: Colors.red,
                            ),
                            
                            // Second notification example
                            const NotificationCard(
                              title: "Battery Low",
                              message: "Robot battery level is below 15%. Please connect to charger.",
                              timestamp: "11:45 AM",
                              icon: Icons.battery_alert,
                              iconColor: Colors.orange,
                              borderColor: Colors.orange,
                            ),
                            
                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 16),

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