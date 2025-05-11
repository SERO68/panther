import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class ServoControl extends StatelessWidget {
  final Function() onUp;
  final Function() onDown;
  final Function() onLeft;
  final Function() onRight;

  const ServoControl({
    Key? key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Servo Control",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Appcolors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 40),
              _buildControlButton(Icons.arrow_upward, onUp),
              const SizedBox(width: 40),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.arrow_back, onLeft),
              const SizedBox(width: 20),
              _buildControlButton(Icons.arrow_forward, onRight),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 40),
              _buildControlButton(Icons.arrow_downward, onDown),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Function() onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Appcolors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}