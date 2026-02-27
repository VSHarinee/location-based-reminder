// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart';
//
// class VoiceInputPage extends StatefulWidget {
//   const VoiceInputPage({Key? key}) : super(key: key);
//
//   @override
//   State<VoiceInputPage> createState() => _VoiceInputPageState();
// }
//
// class _VoiceInputPageState extends State<VoiceInputPage> {
//   final SpeechToText _speech = SpeechToText();
//
//   bool _speechAvailable = false;
//   bool _isListening = false;
//   String _recognizedText = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }
//
//   // 🔹 INIT SPEECH WITH DEBUG LOGS
//   Future<void> _initSpeech() async {
//     _speechAvailable = await _speech.initialize(
//       onStatus: (status) {
//         debugPrint("Speech status: $status");
//       },
//       onError: (error) {
//         debugPrint("Speech error: $error");
//       },
//     );
//
//     debugPrint("Speech available: $_speechAvailable");
//
//     if (!_speechAvailable) {
//       setState(() {
//         _recognizedText = "Speech recognition not available on this device";
//       });
//     }
//   }
//
//   // 🔹 START LISTENING
//   Future<void> _startListening() async {
//     if (!_speechAvailable) return;
//
//     await _speech.listen(
//       localeId: 'en_IN', // Indian English
//       listenMode: ListenMode.confirmation,
//       onResult: (result) {
//         // show ONLY final recognized text (more reliable)
//         if (result.finalResult) {
//           setState(() {
//             _recognizedText = result.recognizedWords;
//           });
//         }
//       },
//     );
//
//     setState(() {
//       _isListening = true;
//     });
//   }
//
//   // 🔹 STOP LISTENING
//   Future<void> _stopListening() async {
//     await _speech.stop();
//     setState(() {
//       _isListening = false;
//     });
//   }
//
//   // 🔹 RETURN TEXT TO PREVIOUS PAGE
//   void _submitText() {
//     if (_recognizedText.trim().isEmpty) return;
//     Navigator.pop(context, _recognizedText.trim());
//   }
//
//   @override
//   void dispose() {
//     _speech.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Voice Reminder Input"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Text(
//                   _recognizedText.isEmpty
//                       ? "Tap the mic and speak"
//                       : _recognizedText,
//                   style: const TextStyle(fontSize: 18),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             FloatingActionButton(
//               onPressed: _isListening ? _stopListening : _startListening,
//               child: Icon(_isListening ? Icons.stop : Icons.mic),
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: _recognizedText.isNotEmpty ? _submitText : null,
//               child: const Text("Use this text"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({Key? key}) : super(key: key);

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final SpeechToText _speech = SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;

  // Live recognized text
  String _recognizedText = "";

  // ✅ Final text (after user edits)
  String _finalTextForNLP = "";

  double _micLevel = -2.0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint("Speech status: $status"),
      onError: (error) {
        debugPrint("Speech error: $error");

        if (error.errorMsg == "error_speech_timeout") {
          debugPrint("Speech timeout ignored");
          return;
        }

        setState(() {
          _isListening = false;
        });
      },
    );
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;

    final systemLocale = await _speech.systemLocale();

    await _speech.listen(
      localeId: systemLocale?.localeId,
      listenMode: ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 6),
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          _micLevel = level.clamp(-2.0, 2.0);
        });
      },
    );

    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _micLevel = -2.0;
    });
  }

  // 🧠 STEP: Show editable popup before saving
  Future<void> _showEditDialog() async {
    final TextEditingController controller =
    TextEditingController(text: _recognizedText);

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit reminder text"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Edit your reminder text here",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    // ✅ User pressed SAVE
    if (result != null && result.isNotEmpty) {
      _finalTextForNLP = result;
      debugPrint("Final text for NLP: $_finalTextForNLP");

      // Return final edited text
      Navigator.pop(context, _finalTextForNLP);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Reminder Input"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  _recognizedText.isEmpty
                      ? (_isListening
                      ? "Listening… Speak now"
                      : "Tap the mic and speak")
                      : _recognizedText,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            if (_isListening)
              LinearProgressIndicator(
                value: (_micLevel + 2) / 4,
                minHeight: 6,
              ),

            const SizedBox(height: 20),

            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.stop : Icons.mic),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
              _recognizedText.isNotEmpty ? _showEditDialog : null,
              child: const Text("Use this text"),
            ),
          ],
        ),
      ),
    );
  }
}
