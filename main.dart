import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NoiseRemovalProvider.dart';
import 'mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization for path_provider

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
      home: MainScreen(), // MainScreen is now wrapped inside the provider context
    );
  }
}
