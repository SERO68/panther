import 'package:flutter/material.dart';
import 'package:panther/core/routes/approutes.dart';

import 'core/routes/routefunc.dart';

void main() {  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app orientation to landscape
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeRight,
  //   DeviceOrientation.landscapeLeft,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute:  Approutename.connecttion,
       onGenerateRoute: onGenerateRoute,
    );
  }
}
