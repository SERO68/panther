import 'package:flutter/material.dart';
import 'package:panther/Routes/approutes.dart';

import '../widgets/notificartioncard.dart';
import '../widgets/shiftcard.dart';
import 'controlscreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("images/blacklogo.png"),
                          radius: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome Mr", style: TextStyle(fontSize: 14)),
                            Text("John Doe",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Approutename.control);
                        },
                        icon: const Icon(
                          Icons.control_camera_rounded,
                          color: Color(0xFF00ADDA),
                          size: 30,
                        ))
                  ],
                ),
                const SizedBox(height: 16),
                if (notifi1)
                  Dismissible(
                    key: deletekey,
                    onDismissed: (_) {
                      setState(() {
                        notifi1 = false;
                      });
                    },
                    child: const NotificationCard(),
                  ),
                const SizedBox(height: 16),
                if (notifi2)
                  Dismissible(
                    key: deletekey2,
                    onDismissed: (_) {
                      setState(() {
                        notifi2 = false;
                      });
                    },
                    child: const NotificationCard(),
                  ),
                if (!notifi1 && !notifi2)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: Text(
                      "There is no problems have a break!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 16),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Shifts",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                const Shiftcard(
                  completed: false,
                  checkin: '10:00',
                  checkout: 'Present',
                  name: 'Ahmed Mostafa',
                  payment: '180\$',
                ),
                const SizedBox(height: 16),
                const Shiftcard(
                  completed: true,
                  checkin: '10:00',
                  checkout: '08:00',
                  name: 'Mostafa Wael',
                  payment: '180\$',
                ),
                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 16),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Reports",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reportcard(
                          icon: Icons.person,
                          number: '12',
                          description: "Persons inside",
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        reportcard(
                          icon: Icons.check,
                          number: '6',
                          description: "Done work",
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reportcard(
                          icon: Icons.attach_money_outlined,
                          number: '600\$',
                          description: "Total paid",
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
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
        color: Color(0xFFF1F2F6),
        elevation: 5,
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.black),
                SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        number,
                        style:
                            TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
