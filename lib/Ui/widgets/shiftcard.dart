import 'package:flutter/material.dart';
import 'package:panther/Ui/widgets/icontext.dart';

class Shiftcard extends StatelessWidget {
  const Shiftcard({
    super.key,
    required this.completed,
    required this.checkin,
    required this.checkout,
    required this.name,
    required this.payment,
  });

  final bool completed;
  final String checkin;
  final String checkout;
  final String name;
  final String payment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF1F2F6),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: completed
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : const Color(0xFF00ADDA),
                  ),
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(completed? Icons.check : Icons.alarm_rounded,
                         size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          completed ? "Completed" : "Active",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      checkin,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5),
                    const Text("-"),
                    const SizedBox(width: 5),
                    Text(checkout),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Name, Payment, and Checkboxes Section
            Row(
              children: [
                // Left Column: Name and Payment
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTextWidget2(icon: Icons.person_4_rounded, text: name),
                      const SizedBox(height: 10),
                      IconTextWidget2(icon: Icons.wallet, text: payment),
                    ],
                  ),
                ),
                // Right Column: Checkboxes
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const IconTextWidget2(
                      space: 18,
                      icon: Icons.check_box_outlined,
                      text: "Check in",
                    ),
                    const SizedBox(height: 8),
                    IconTextWidget2(
                      icon: completed
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank_rounded,
                      text: "Check out",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
