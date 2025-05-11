import 'package:flutter/material.dart';
import 'package:panther/Routes/approutes.dart';
import 'package:panther/Ui/Screens/homescreen.dart';
import 'package:panther/Ui/Screens/controlscreen.dart';

import '../Ui/Screens/connectionscreen.dart';

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
