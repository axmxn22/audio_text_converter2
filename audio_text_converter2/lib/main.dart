// Importation du package Flutter pour créer l'interface utilisateur
import 'package:flutter/material.dart';

// Importation de l’écran principal de l’application (qui est dans le dossier screens)
import 'screens/audio_text_converter_screen.dart';

// Fonction principale : point d’entrée de l’application
void main() {
  runApp(const AudioTextConverterApp()); // Lance l'application
}

// Classe principale de l’application (widget racine)
class AudioTextConverterApp extends StatelessWidget {
  const AudioTextConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioText Converter', // Titre de l'application
      debugShowCheckedModeBanner:
          false, // Cache le bandeau "debug" en haut à droite
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Couleur principale de l’appli
        scaffoldBackgroundColor: Colors.grey[100], // Couleur de fond
      ),
      home: const AudioTextConverterScreen(),
      // Point d’entrée visuel de l’appli (écran que tu as défini dans audio_text_converter_screen.dart)
    );
  }
}
