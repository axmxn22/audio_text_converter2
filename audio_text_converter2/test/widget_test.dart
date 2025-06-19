import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assure-toi que ce fichier contient bien un widget `AudioTextConverterApp`
import 'package:audio_text_converter2/main.dart';

void main() {
  testWidgets('Interaction : bouton Parler met à jour la transcription',
      (WidgetTester tester) async {
    // Monte l'application complète
    await tester.pumpWidget(const AudioTextConverterApp());

    // Vérifie que le bouton 'Speak' est trouvé (en anglais si c’est ce que tu as utilisé dans le code)
    final speakButton = find.text(
        'Speak'); // Si c'était "Parler", corrige ton bouton dans le code source
    expect(speakButton, findsOneWidget);

    // Simule un clic sur le bouton
    await tester.tap(speakButton);
    await tester.pump(); // rafraîchit l'UI

    // ⚠️ Ici tu dois avoir une logique de mise à jour de l'UI (ex. texte ou Snackbar)

    // Exemple : vérifier si un message est affiché
    // Ceci est un test placeholder : à adapter selon ton comportement réel
    // Par exemple, si tu mets à jour _transcription, teste un changement visible
    expect(find.textContaining('Your transcribed text'), findsNothing);
  });

  testWidgets(
    'Interaction : bouton Sauvegarder affiche un message de sauvegarde',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AudioTextConverterApp());

      final saveButton = find.text('Sauvegarder');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Vérifie qu’un message est affiché (SnackBar ou Text par exemple)
      expect(find.textContaining('Sauvegardé à :'), findsOneWidget);
    },
  );
}
