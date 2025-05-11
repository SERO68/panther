import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../../../core/theme/colors.dart';

class CustomJoystick extends StatelessWidget {
  final Function(double, double) onDirectionChanged;

  const CustomJoystick({
    super.key,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Joystick(
      base: JoystickBase(
        decoration: JoystickBaseDecoration(
          color: Colors.black,
          drawOuterCircle: false,
        ),
        arrowsDecoration: JoystickArrowsDecoration(
          color: Appcolors.primary,
        ),
      ),
      listener: (details) {
        onDirectionChanged(details.x, details.y);
        log('Joystick direction: ${details.x}, ${details.y}');
      },
      mode: JoystickMode.all,
    );
  }
}