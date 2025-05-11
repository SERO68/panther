import 'package:flutter/material.dart';
import 'package:panther/core/routes/approutes.dart';
import 'package:panther/features/home/screens/homescreen.dart';
import 'package:panther/features/control/screens/controlscreen.dart';
import 'package:panther/features/connection/screens/connectionscreen.dart';

Route? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Approutename.home:
      return MaterialPageRoute(builder: (context) => const Homescreen());
    case Approutename.control:
      return MaterialPageRoute(builder: (context) => const Controlscreen());
    case Approutename.connecttion:
      return MaterialPageRoute(builder: (context) => const ConnectionScreen());

    default:
      return null;
  }
}