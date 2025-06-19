import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';

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
      home: const AudioTextConverterScreen(),
    );
  }
}

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
  String _transcription = 'Your transcribed text will appear here...';
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
        title: const Text('AudioText Converter'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.cog),
            onPressed: () {
              // TODO: paramètres
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.history),
            onPressed: () {
              // TODO: historique
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: FaIcon(FontAwesomeIcons.microphone),
              text: 'Audio to Text',
            ),
            Tab(icon: FaIcon(FontAwesomeIcons.keyboard), text: 'Text to Audio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Audio to Text tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const FaIcon(
                          FontAwesomeIcons.fileAudio,
                          color: Colors.blue,
                        ),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _chooseAudioFile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const FaIcon(
                          FontAwesomeIcons.microphone,
                          color: Colors.red,
                        ),
                        label: Text(_isListening ? 'Stop' : 'Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red[400]
                              : Colors.red[100],
                          foregroundColor: Colors.red[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isListening
                            ? _stopListening
                            : _startListening,
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
                          children: List.generate(8, (i) => _buildWaveBar(i)),
                        ),
                        Text(
                          _formatDuration(_recordingSeconds),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.stop,
                            color: Colors.white,
                          ),
                          label: const Text('Stop Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _stopListening,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transcription Language',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedLang,
                      items: const [
                        DropdownMenuItem(
                          value: 'en_US',
                          child: Text('English (United States)'),
                        ),
                        DropdownMenuItem(
                          value: 'fr_FR',
                          child: Text('French (France)'),
                        ),
                        DropdownMenuItem(
                          value: 'es_ES',
                          child: Text('Spanish (Spain)'),
                        ),
                        DropdownMenuItem(
                          value: 'de_DE',
                          child: Text('German (Germany)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedLang = value;
                        });
                      },
                    ),
                  ],
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
                  child: SelectableText(
                    _transcription,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),

          // Text to Audio tab
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
                      hintText: 'Type your text here...',
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
                            value: 'en-US',
                            child: Text('English (US)'),
                          ),
                          DropdownMenuItem(
                            value: 'fr-FR',
                            child: Text('French (France)'),
                          ),
                          DropdownMenuItem(
                            value: 'es-ES',
                            child: Text('Spanish (Spain)'),
                          ),
                          DropdownMenuItem(
                            value: 'de-DE',
                            child: Text('German (Germany)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedVoiceLang = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.volumeUp, size: 18),
                      label: const Text('Speak'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _speakText,
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
