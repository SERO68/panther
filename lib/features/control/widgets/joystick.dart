import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../../../core/theme/colors.dart';

class CustomJoystick extends StatelessWidget {
  final Function(double, double) onDirectionChanged;
  final Function onStickDragEnd;

  const CustomJoystick({
    super.key,
    required this.onDirectionChanged, required this.onStickDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Joystick( onStickDragEnd: onStickDragEnd,
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