import 'package:flutter/material.dart';
import 'screens/audio_text_converter_screen.dart'; // <- importe l'écran

void main() {
  runApp(const AudioTextConverterApp());
}

class AudioTextConverterApp extends StatelessWidget {
  const AudioTextConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioText Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AudioTextConverterScreen(), // <-- utilise ton écran ici
    );
  }
}
