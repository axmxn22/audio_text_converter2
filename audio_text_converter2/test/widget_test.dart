// Removed unused import
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/audio_text_converter_screen.dart';

void main() {
  testWidgets('Interaction : bouton Parler met à jour la transcription', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
        const AudioTextConverterApp()); // Ensure the function is defined or imported

    final speakButton = find.text('Parler');
    expect(speakButton, findsOneWidget);

    // Simule le clic sur le bouton Parler
    await tester.tap(speakButton);
    await tester.pump();

    // Vérifie que la transcription est bien mise à jour
    expect(find.text('Aucune transcription'), findsNothing);
  });

  testWidgets(
    'Interaction : bouton Sauvegarder affiche un message de sauvegarde',
    (WidgetTester tester) async {
      await tester.pumpWidget(AudioTextConverterApp());

      final saveButton = find.text('Sauvegarder');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Vérifie que le message de sauvegarde est affiché
      expect(find.text('Sauvegardé à :'), findsOneWidget);
    },
  );
}
