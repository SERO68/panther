import 'package:flutter/material.dart';
import 'package:panther/core/routes/approutes.dart';

import 'core/routes/routefunc.dart';

void main() {  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panther',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute:  Approutename.connecttion,
       onGenerateRoute: onGenerateRoute,
    );
  }
}
