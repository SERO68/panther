import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final double space;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final MainAxisSize mainAxisSize;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.space = 8.0,
    this.textStyle,
    this.iconColor,
    this.iconSize = 20,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: [
        Container(
          width: 24, // Fixed width for the icon
          alignment: Alignment.centerLeft, // Align icon to the left
          child: Icon(icon, color: iconColor ?? Colors.black, size: iconSize),
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