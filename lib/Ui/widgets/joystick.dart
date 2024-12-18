import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../../Theme/colors.dart';

class CustomJoystick extends StatelessWidget {
  const CustomJoystick({super.key});

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
        log('Joystick direction: ${details.x}, ${details.y}');
      },
      mode: JoystickMode.all,
    );
  }
}
