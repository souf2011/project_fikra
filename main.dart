import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NoiseRemovelProvider.dart';
import 'mainscreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoiseRemovalProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Noise Remover',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );

  }
}
