import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class AlarmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AlarmButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: onPressed,
      child: const Icon(Icons.warning, color: Appcolors.error),
    );
  }
}