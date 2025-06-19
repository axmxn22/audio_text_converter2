// Importation des bibliothèques nécessaires
import 'dart:async'; // Pour le timer
import 'package:flutter/material.dart'; // UI de base Flutter
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pour les icônes FontAwesome
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Pour la reconnaissance vocale
import 'package:flutter_tts/flutter_tts.dart'; // Pour la synthèse vocale (Text-to-Speech)
import 'package:file_picker/file_picker.dart'; // Pour sélectionner un fichier audio

void main() {
  runApp(
      const AudioTextConverterApp()); // Point d’entrée principal de l’application
}

// Widget racine de l'application
class AudioTextConverterApp extends StatelessWidget {
  const AudioTextConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertisseur AudioTexte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AudioTextConverterScreen(), // Écran principal
    );
  }
}

// Écran principal avec les deux onglets
class AudioTextConverterScreen extends StatefulWidget {
  const AudioTextConverterScreen({super.key});

  @override
  State<AudioTextConverterScreen> createState() =>
      _AudioTextConverterScreenState();
}

class _AudioTextConverterScreenState extends State<AudioTextConverterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcription = 'Votre texte transcrit apparaîtra ici...';
  String _selectedLang = 'fr_FR';

  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _recordingActive = false;

  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  String _selectedVoiceLang = 'fr-FR';

  String? _selectedAudioFilePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recordingTimer?.cancel();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      setState(() {
        _transcription = "Microphone non disponible";
      });
      return;
    }
    setState(() {
      _isListening = true;
      _recordingActive = true;
      _transcription = '';
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
    _speech.listen(
      localeId: _selectedLang,
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
          if (result.finalResult) {
            _stopListening();
          }
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _recordingActive = false;
    });
    _recordingTimer?.cancel();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _speakText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await _flutterTts.setLanguage(_selectedVoiceLang);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _chooseAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedAudioFilePath = result.files.first.path;
        _transcription = 'Fichier sélectionné : ${result.files.first.name}';
      });
    } else {
      setState(() {
        _transcription = 'Aucun fichier sélectionné.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertisseur AudioTexte'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.cog),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.history),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: FaIcon(FontAwesomeIcons.microphone),
              text: 'Audio en Texte',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.volumeHigh),
              text: 'Texte en Audio',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Audio en Texte
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.fileAudio,
                            color: Colors.blue),
                        label: const Text('Choisir un fichier'),
                        onPressed: _chooseAudioFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.microphone,
                            color: Colors.red),
                        label: Text(_isListening ? 'Arrêter' : 'Enregistrer'),
                        onPressed:
                            _isListening ? _stopListening : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isListening ? Colors.red[400] : Colors.red[100],
                          foregroundColor: Colors.red[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isListening)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            children:
                                List.generate(8, (i) => _buildWaveBar(i))),
                        Text(_formatDuration(_recordingSeconds)),
                        ElevatedButton.icon(
                          icon: const FaIcon(FontAwesomeIcons.stop,
                              color: Colors.white),
                          label: const Text('Stop'),
                          onPressed: _stopListening,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Text('Langue de transcription',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedLang,
                  items: const [
                    DropdownMenuItem(
                        value: 'en_US', child: Text('Anglais (États-Unis)')),
                    DropdownMenuItem(
                        value: 'fr_FR', child: Text('Français (France)')),
                    DropdownMenuItem(
                        value: 'es_ES', child: Text('Espagnol (Espagne)')),
                    DropdownMenuItem(
                        value: 'de_DE', child: Text('Allemand (Allemagne)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLang = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  constraints: const BoxConstraints(minHeight: 120),
                  child: SelectableText(_transcription),
                ),
              ],
            ),
          ),
          // Onglet Texte en Audio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre texte ici...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedVoiceLang,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'en-US', child: Text('Anglais (US)')),
                          DropdownMenuItem(
                              value: 'fr-FR', child: Text('Français (France)')),
                          DropdownMenuItem(
                              value: 'es-ES',
                              child: Text('Espagnol (Espagne)')),
                          DropdownMenuItem(
                              value: 'de-DE',
                              child: Text('Allemand (Allemagne)')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedVoiceLang = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.volumeHigh, size: 18),
                      label: const Text('Lire'),
                      onPressed: _speakText,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 4,
      height: _recordingActive ? (index.isEven ? 30 : 15) : 10,
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(2),
      ),
      transform: Matrix4.translationValues(
        0,
        _recordingSeconds % 2 == 0 ? 5 : -5,
        0,
      ),
    );
  }
}
