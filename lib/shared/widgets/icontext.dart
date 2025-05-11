import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final double space;
  final TextStyle? textStyle;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.space = 8.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24, // Fixed width for the icon
          alignment: Alignment.centerLeft, // Align icon to the left
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        SizedBox(width: space), // Space between icon and text
        Text(
          text,
          style: textStyle ?? const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}