// // import 'package:flutter/material.dart';
// // import 'package:speech_to_text/speech_to_text.dart';
// //
// // class VoiceInputPage extends StatefulWidget {
// //   const VoiceInputPage({Key? key}) : super(key: key);
// //
// //   @override
// //   State<VoiceInputPage> createState() => _VoiceInputPageState();
// // }
// //
// // class _VoiceInputPageState extends State<VoiceInputPage> {
// //   final SpeechToText _speech = SpeechToText();
// //
// //   bool _speechAvailable = false;
// //   bool _isListening = false;
// //   String _recognizedText = "";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initSpeech();
// //   }
// //
// //   // 🔹 INIT SPEECH WITH DEBUG LOGS
// //   Future<void> _initSpeech() async {
// //     _speechAvailable = await _speech.initialize(
// //       onStatus: (status) {
// //         debugPrint("Speech status: $status");
// //       },
// //       onError: (error) {
// //         debugPrint("Speech error: $error");
// //       },
// //     );
// //
// //     debugPrint("Speech available: $_speechAvailable");
// //
// //     if (!_speechAvailable) {
// //       setState(() {
// //         _recognizedText = "Speech recognition not available on this device";
// //       });
// //     }
// //   }
// //
// //   // 🔹 START LISTENING
// //   Future<void> _startListening() async {
// //     if (!_speechAvailable) return;
// //
// //     await _speech.listen(
// //       localeId: 'en_IN', // Indian English
// //       listenMode: ListenMode.confirmation,
// //       onResult: (result) {
// //         // show ONLY final recognized text (more reliable)
// //         if (result.finalResult) {
// //           setState(() {
// //             _recognizedText = result.recognizedWords;
// //           });
// //         }
// //       },
// //     );
// //
// //     setState(() {
// //       _isListening = true;
// //     });
// //   }
// //
// //   // 🔹 STOP LISTENING
// //   Future<void> _stopListening() async {
// //     await _speech.stop();
// //     setState(() {
// //       _isListening = false;
// //     });
// //   }
// //
// //   // 🔹 RETURN TEXT TO PREVIOUS PAGE
// //   void _submitText() {
// //     if (_recognizedText.trim().isEmpty) return;
// //     Navigator.pop(context, _recognizedText.trim());
// //   }
// //
// //   @override
// //   void dispose() {
// //     _speech.stop();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Voice Reminder Input"),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             Expanded(
// //               child: Center(
// //                 child: Text(
// //                   _recognizedText.isEmpty
// //                       ? "Tap the mic and speak"
// //                       : _recognizedText,
// //                   style: const TextStyle(fontSize: 18),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 20),
// //
// //             FloatingActionButton(
// //               onPressed: _isListening ? _stopListening : _startListening,
// //               child: Icon(_isListening ? Icons.stop : Icons.mic),
// //             ),
// //
// //             const SizedBox(height: 20),
// //
// //             ElevatedButton(
// //               onPressed: _recognizedText.isNotEmpty ? _submitText : null,
// //               child: const Text("Use this text"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
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
//
//   // Live recognized text
//   String _recognizedText = "";
//
//   // ✅ Final text (after user edits)
//   String _finalTextForNLP = "";
//
//   double _micLevel = -2.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }
//
//   Future<void> _initSpeech() async {
//     _speechAvailable = await _speech.initialize(
//       onStatus: (status) => debugPrint("Speech status: $status"),
//       onError: (error) {
//         debugPrint("Speech error: $error");
//
//         if (error.errorMsg == "error_speech_timeout") {
//           debugPrint("Speech timeout ignored");
//           return;
//         }
//
//         setState(() {
//           _isListening = false;
//         });
//       },
//     );
//   }
//
//   Future<void> _startListening() async {
//     if (!_speechAvailable) return;
//
//     final systemLocale = await _speech.systemLocale();
//
//     await _speech.listen(
//       localeId: systemLocale?.localeId,
//       listenMode: ListenMode.dictation,
//       partialResults: true,
//       listenFor: const Duration(seconds: 20),
//       pauseFor: const Duration(seconds: 6),
//       onResult: (result) {
//         setState(() {
//           _recognizedText = result.recognizedWords;
//         });
//       },
//       onSoundLevelChange: (level) {
//         setState(() {
//           _micLevel = level.clamp(-2.0, 2.0);
//         });
//       },
//     );
//
//     setState(() {
//       _isListening = true;
//     });
//   }
//
//   Future<void> _stopListening() async {
//     await _speech.stop();
//     setState(() {
//       _isListening = false;
//       _micLevel = -2.0;
//     });
//   }
//
//   // 🧠 STEP: Show editable popup before saving
//   Future<void> _showEditDialog() async {
//     final TextEditingController controller =
//     TextEditingController(text: _recognizedText);
//
//     final result = await showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Edit reminder text"),
//           content: TextField(
//             controller: controller,
//             maxLines: 4,
//             autofocus: true,
//             decoration: const InputDecoration(
//               hintText: "Edit your reminder text here",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, controller.text.trim());
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//
//     // ✅ User pressed SAVE
//     if (result != null && result.isNotEmpty) {
//       _finalTextForNLP = result;
//       debugPrint("Final text for NLP: $_finalTextForNLP");
//
//       // Return final edited text
//       Navigator.pop(context, _finalTextForNLP);
//     }
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
//                       ? (_isListening
//                       ? "Listening… Speak now"
//                       : "Tap the mic and speak")
//                       : _recognizedText,
//                   style: const TextStyle(fontSize: 18),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//
//             if (_isListening)
//               LinearProgressIndicator(
//                 value: (_micLevel + 2) / 4,
//                 minHeight: 6,
//               ),
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
//               onPressed:
//               _recognizedText.isNotEmpty ? _showEditDialog : null,
//               child: const Text("Use this text"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:math' as math;

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({Key? key}) : super(key: key);

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage>
    with TickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;

  // Live recognized text
  String _recognizedText = "";

  // ✅ Final text (after user edits)
  String _finalTextForNLP = "";

  double _micLevel = -2.0;

  // ── UI-only additions ────────────────────────────────────────────────────
  late AnimationController _masterController;
  late AnimationController _orbController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _successController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardScale;
  late Animation<double> _orbRotate;
  late Animation<double> _pulseScale;
  late Animation<double> _waveAnim;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;

  // ── Light theme palette ──────────────────────────────────────────────────
  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFF60A5FA);
  static const _accentGlow = Color(0xFFBAE6FD);
  static const _bg = Color(0xFFF0F6FF);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _errorColor = Color(0xFFDC2626);
  static const _successColor = Color(0xFF16A34A);
  static const _voiceGradient = [Color(0xFF8B5CF6), Color(0xFFA78BFA)];

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeIn = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.13),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
    ));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _orbRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbController, curve: Curves.linear));
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacity = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.4),
    );

    _masterController.forward();
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
    setState(() {});
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
    HapticFeedback.mediumImpact();
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _micLevel = -2.0;
    });
    HapticFeedback.lightImpact();
  }

  // 🧠 STEP: Show editable popup before saving
  Future<void> _showEditDialog() async {
    final TextEditingController controller =
    TextEditingController(text: _recognizedText);

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: _textPrimary.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _voiceGradient[0].withOpacity(0.08),
                        _voiceGradient[1].withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _voiceGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _voiceGradient[0].withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Reminder Text",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "Review and refine your message",
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RECOGNIZED TEXT",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: _border),
                        ),
                        child: TextField(
                          controller: controller,
                          maxLines: 5,
                          autofocus: true,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Edit your reminder text here...",
                            hintStyle: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context, null);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: _border),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context, controller.text.trim());
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _voiceGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: _voiceGradient[0].withOpacity(0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Save & Continue",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // ✅ User pressed SAVE
    if (result != null && result.isNotEmpty) {
      _finalTextForNLP = result;
      debugPrint("Final text for NLP: $_finalTextForNLP");

      // Show success animation
      setState(() {});
      await _successController.forward();
      await Future.delayed(const Duration(milliseconds: 300));

      // Return final edited text
      if (mounted) {
        Navigator.pop(context, _finalTextForNLP);
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _orbController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _successController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _orbRotate,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _LightBackgroundPainter(rotation: _orbRotate.value),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SlideTransition(
                        position: _cardSlide,
                        child: ScaleTransition(
                          scale: _cardScale,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildInstructionCard(),
                                const SizedBox(height: 20),
                                _buildMicrophoneCard(),
                                const SizedBox(height: 20),
                                _buildTranscriptCard(),
                                const SizedBox(height: 20),
                                if (_recognizedText.isNotEmpty)
                                  _buildUseTextButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: _textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Voice Reminder",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Speak your reminder naturally",
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _voiceGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: _voiceGradient[0].withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Instruction Card ──────────────────────────────────────────────────────
  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accent.withOpacity(0.13),
                      _accentLight.withOpacity(0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _accent.withOpacity(0.18)),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: _accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How It Works",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      "Follow these simple steps",
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          _buildStep(1, "Tap the microphone", Icons.mic_rounded),
          const SizedBox(height: 12),
          _buildStep(2, "Speak your reminder clearly", Icons.record_voice_over_rounded),
          const SizedBox(height: 12),
          _buildStep(3, "Review and save the text", Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accent.withOpacity(0.15),
                _accentLight.withOpacity(0.08),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: _accent.withOpacity(0.25)),
          ),
          child: Center(
            child: Text(
              "$number",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 16, color: _textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Microphone Card ───────────────────────────────────────────────────────
  Widget _buildMicrophoneCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isListening
              ? _voiceGradient
              : [_surface, _surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _isListening
              ? _voiceGradient[0].withOpacity(0.5)
              : _border,
          width: _isListening ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isListening
                ? _voiceGradient[0].withOpacity(0.35)
                : _accent.withOpacity(0.06),
            blurRadius: _isListening ? 32 : 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings (when listening)
              if (_isListening) ...[
                AnimatedBuilder(
                  animation: _pulseScale,
                  builder: (_, __) => Container(
                    width: 160 * _pulseScale.value,
                    height: 160 * _pulseScale.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseScale,
                  builder: (_, __) => Container(
                    width: 140 * (2 - _pulseScale.value),
                    height: 140 * (2 - _pulseScale.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],

              // Main microphone button
              GestureDetector(
                onTap: _speechAvailable
                    ? (_isListening ? _stopListening : _startListening)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.white.withOpacity(0.25)
                        : _surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isListening
                          ? Colors.white.withOpacity(0.4)
                          : _voiceGradient[0].withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isListening
                            ? Colors.white.withOpacity(0.3)
                            : _voiceGradient[0].withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 48,
                    color: _isListening ? Colors.white : _voiceGradient[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _isListening
                ? "Listening..."
                : (_speechAvailable
                ? "Tap to start"
                : "Initializing..."),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _isListening ? Colors.white : _textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isListening
                ? "Speak clearly into your microphone"
                : "Press the microphone and speak",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _isListening
                  ? Colors.white.withOpacity(0.85)
                  : _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isListening) ...[
            const SizedBox(height: 24),
            _buildSoundWave(),
          ],
        ],
      ),
    );
  }

  // ── Sound Wave Visualization ──────────────────────────────────────────────
  Widget _buildSoundWave() {
    final normalizedLevel = (_micLevel + 2) / 4;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _waveAnim,
                builder: (_, __) {
                  final phase = (index * 0.2) + _waveAnim.value;
                  final height = 10 + (math.sin(phase * 2 * math.pi) * 20 * normalizedLevel);

                  return Container(
                    width: 4,
                    height: height.clamp(8.0, 40.0),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: normalizedLevel,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Transcript Card ───────────────────────────────────────────────────────
  Widget _buildTranscriptCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        minHeight: _recognizedText.isEmpty ? 120 : 150,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _recognizedText.isNotEmpty
              ? _successColor.withOpacity(0.3)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: _recognizedText.isNotEmpty
                ? _successColor.withOpacity(0.08)
                : _accent.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _recognizedText.isNotEmpty
                        ? [
                      _successColor.withOpacity(0.15),
                      _successColor.withOpacity(0.08),
                    ]
                        : [
                      _accent.withOpacity(0.13),
                      _accentLight.withOpacity(0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _recognizedText.isNotEmpty
                        ? _successColor.withOpacity(0.25)
                        : _accent.withOpacity(0.18),
                  ),
                ),
                child: Icon(
                  _recognizedText.isNotEmpty
                      ? Icons.check_circle_outline_rounded
                      : Icons.text_fields_rounded,
                  color: _recognizedText.isNotEmpty ? _successColor : _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recognizedText.isNotEmpty
                          ? "Recognized Text"
                          : "Transcript",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      _recognizedText.isNotEmpty
                          ? "Your message is ready"
                          : "Your speech will appear here",
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                _recognizedText.isEmpty
                    ? (_isListening
                    ? "Listening... speak now"
                    : "Tap the mic and speak")
                    : _recognizedText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _recognizedText.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
                  color: _recognizedText.isEmpty
                      ? _textSecondary
                      : _textPrimary,
                  height: 1.5,
                ),
                textAlign: _recognizedText.isEmpty
                    ? TextAlign.center
                    : TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Use Text Button ───────────────────────────────────────────────────────
  Widget _buildUseTextButton() {
    return GestureDetector(
      onTap: _showEditDialog,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _voiceGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _voiceGradient[0].withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done_all_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                "Use This Text",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Light background painter ───────────────────────────────────────────────
class _LightBackgroundPainter extends CustomPainter {
  final double rotation;
  _LightBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    // Soft white-blue base
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFF6FF),
          Color(0xFFF0F6FF),
          Color(0xFFE8F0FE),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Orb 1 — large blue top-right
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.88 + math.cos(rotation) * 22,
        size.height * 0.12 + math.sin(rotation) * 16,
      ),
      radius: size.width * 0.52,
      innerColor: const Color(0xFF2563EB).withOpacity(0.07),
    );

    // Orb 2 — sky bottom-left
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.08 + math.cos(rotation + math.pi) * 18,
        size.height * 0.82 + math.sin(rotation + math.pi) * 14,
      ),
      radius: size.width * 0.46,
      innerColor: const Color(0xFF60A5FA).withOpacity(0.09),
    );

    // Orb 3 — tiny accent center
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.5 + math.cos(rotation * 0.6) * 30,
        size.height * 0.42 + math.sin(rotation * 0.6) * 20,
      ),
      radius: size.width * 0.28,
      innerColor: const Color(0xFFBAE6FD).withOpacity(0.12),
    );

    // Subtle dot grid
    _drawDotGrid(canvas, size);
  }

  void _drawOrb(Canvas canvas,
      {required Offset center,
        required double radius,
        required Color innerColor}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [innerColor, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.055)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    const dotR = 1.2;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LightBackgroundPainter old) => old.rotation != rotation;
}