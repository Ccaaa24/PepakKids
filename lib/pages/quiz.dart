import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/app_theme.dart';
import 'result.dart';

final supabase = Supabase.instance.client;

// Quiz Page - Standalone page untuk quiz
class QuizPage extends StatefulWidget {
  final String levelId;
  
  const QuizPage({
    super.key,
    required this.levelId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _loading = true;
  List<dynamic> _questions = [];
  int _quizIndex = 0;
  int _score = 0;

  // Answer tracking
  final List<Map<String, dynamic>> _answers = [];
  String? _selectedAnswer;
  bool _showAnswerFeedback = false;
  bool _isAnswerCorrect = false;

  // Audio player state
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _fetchData();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final quiz = await supabase
          .from('quiz')
          .select('quiz_id, tipe, pilihan, jawaban, pertanyaan, quiz_aset(aset(url, jenis))')
          .eq('level_id', widget.levelId)
          .order('urutan');

      setState(() {
        _questions = quiz;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching quiz: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _currentAudioUrl = null;
          _isPlayingAudio = false;
        });
      }
    }
  }

  Future<void> _togglePlayForUrl(String url) async {
    try {
      if (_currentAudioUrl == url) {
        if (_isPlayingAudio) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
        return;
      }

      await _audioPlayer.stop();
      _currentAudioUrl = url;
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Audio play error: $e');
      if (mounted) {
        setState(() {
          _currentAudioUrl = null;
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _selectAnswer(String selected) {
    // Jangan proses jika sedang menampilkan feedback
    if (_showAnswerFeedback) return;

    final current = _questions[_quizIndex];
    final quizId = current['quiz_id'] as String;
    final correct = current['jawaban'] as String?;

    final isCorrect = correct != null && 
                     selected.trim().toLowerCase() == correct.trim().toLowerCase();

    // Set visual feedback state
    setState(() {
      _selectedAnswer = selected;
      _showAnswerFeedback = true;
      _isAnswerCorrect = isCorrect;
    });

    // Simpan jawaban ke _answers list
    _recordAnswer(quizId, selected, correct);

    // Update skor jika jawaban benar
    if (isCorrect) {
      setState(() {
        _score++;
      });
      debugPrint('✅ Jawaban benar! Skor: $_score');
    } else {
      debugPrint('❌ Jawaban salah. Jawaban benar: $correct, Dipilih: $selected');
    }

    // Delay lebih lama agar user bisa melihat feedback dengan jelas
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _selectedAnswer = null;
          _showAnswerFeedback = false;
          _isAnswerCorrect = false;
        });
        _nextQuiz();
      }
    });
  }

  void _recordAnswer(String quizId, String selected, String? correctAnswer) {
    final idx = _answers.indexWhere((e) => e['quiz_id'] == quizId);
    final answerData = {
      'quiz_id': quizId,
      'selected': selected,
      'correct_answer': correctAnswer,
      'is_correct': correctAnswer != null && 
                   selected.trim().toLowerCase() == correctAnswer.trim().toLowerCase(),
    };

    if (idx >= 0) {
      _answers[idx] = answerData;
    } else {
      _answers.add(answerData);
    }

    debugPrint('📝 Answer recorded: $answerData');
  }

  void _nextQuiz() {
    if (_quizIndex < _questions.length - 1) {
      setState(() {
        _quizIndex++;
      });
      debugPrint('➡️ Next quiz: ${_quizIndex + 1}/${_questions.length}');
    } else {
      debugPrint('🏁 Quiz selesai! Final score: $_score/${_questions.length}');
      _onQuizFinished();
    }
  }

  Future<void> _onQuizFinished() async {
    await _stopAudio();
    
    if (!mounted) return;
    
    // Navigate to result page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          levelId: widget.levelId,
          score: _score,
          totalQuestions: _questions.length,
          answers: _answers,
        ),
      ),
    );

    // Handle result actions
    if (result != null && result is Map<String, dynamic>) {
      final action = result['action'];
      if (action == 'retry') {
        _retryQuiz();
      } else if (action == 'back_to_materi') {
        if (mounted) {
          Navigator.pop(context, {'action': 'back_to_materi'});
        }
      } else if (action == 'finish') {
        if (mounted) {
          Navigator.pop(context, result['refresh'] ?? false);
        }
      }
    }
  }

  void _retryQuiz() {
    setState(() {
      _quizIndex = 0;
      _score = 0;
      _answers.clear();
      _selectedAnswer = null;
      _showAnswerFeedback = false;
      _isAnswerCorrect = false;
    });
    debugPrint('🔄 Retry quiz - Quiz states cleared');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFF5F0E8),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFF5F0E8),
          child: const Center(
            child: Text("Belum ada quiz"),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F0E8),
        child: SafeArea(
          child: Stack(
            children: [
              // Simple back button
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 28, color: Color(0xFF5D4E37)),
                ),
              ),
              
              // Quiz content
              QuizCard(
                questions: _questions,
                quizIndex: _quizIndex,
                onAnswer: _selectAnswer,
                audioPlayer: _audioPlayer,
                currentAudioUrl: _currentAudioUrl,
                isPlayingAudio: _isPlayingAudio,
                onToggleAudio: _togglePlayForUrl,
                selectedAnswer: _selectedAnswer,
                showAnswerFeedback: _showAnswerFeedback,
                isAnswerCorrect: _isAnswerCorrect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quiz Card Widget
class QuizCard extends StatelessWidget {
  final List<dynamic> questions;
  final int quizIndex;
  final Function(String) onAnswer;
  final AudioPlayer audioPlayer;
  final String? currentAudioUrl;
  final bool isPlayingAudio;
  final Function(String) onToggleAudio;
  final String? selectedAnswer;
  final bool showAnswerFeedback;
  final bool isAnswerCorrect;

  const QuizCard({
    super.key,
    required this.questions,
    required this.quizIndex,
    required this.onAnswer,
    required this.audioPlayer,
    required this.currentAudioUrl,
    required this.isPlayingAudio,
    required this.onToggleAudio,
    this.selectedAnswer,
    this.showAnswerFeedback = false,
    this.isAnswerCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: Text("Belum ada quiz"));
    }

    return Column(
      children: [
        const SizedBox(height: 60), // Space for back button
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (quizIndex + 1) / questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 32),

                // Question text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [AppTheme.cardShadow],
                    border: Border.all(
                      color: const Color(0xFFA97142).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    questions[quizIndex]['pertanyaan'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Image asset
                if (questions[quizIndex]['quiz_aset'] != null &&
                    questions[quizIndex]['quiz_aset'].isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      questions[quizIndex]['quiz_aset'][0]['aset']['url'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // Audio player
                _buildAudioPlayer(
                  questions[quizIndex]['quiz_aset'],
                  "Dengarkan audio soal",
                ),

                // Answer options
                ...List<String>.from(questions[quizIndex]['pilihan'] ?? [])
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final opsi = entry.value;

                  // Determine button state
                  final isSelected = selectedAnswer == opsi;
                  final isCorrectAnswer = questions[quizIndex]['jawaban'] == opsi;
                  
                  // Tentukan warna button berdasarkan state
                  Color buttonColor = const Color(0xFFA97142); // Default coklat
                  Color textColor = Colors.white;
                  double elevation = 2;

                  if (showAnswerFeedback && isSelected) {
                    // Button yang dipilih: berubah warna
                    if (isAnswerCorrect) {
                      buttonColor = const Color(0xFF4CAF50); // Hijau jika benar
                      elevation = 4;
                    } else {
                      buttonColor = const Color(0xFFF44336); // Merah jika salah
                      elevation = 4;
                    }
                  } else if (showAnswerFeedback) {
                    // Button lain: opacity menurun
                    buttonColor = const Color(0xFFA97142).withOpacity(0.4);
                    elevation = 1;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: showAnswerFeedback ? null : () => onAnswer(opsi),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        disabledBackgroundColor: buttonColor,
                        disabledForegroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: elevation,
                      ),
                      child: Text(
                        opsi,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer(List<dynamic>? asetList, String label) {
    if (asetList == null || asetList.isEmpty) {
      return const SizedBox.shrink();
    }

    String? audioUrl;
    for (final item in asetList) {
      final aset = item['aset'] as Map<String, dynamic>?;
      final jenis = aset?['jenis'] as String?;
      if (aset != null &&
          jenis != null &&
          jenis.toLowerCase().contains('audio')) {
        audioUrl = aset['url'] as String?;
        break;
      }
    }

    if (audioUrl == null) return const SizedBox.shrink();

    final isThisPlaying = (currentAudioUrl == audioUrl) && isPlayingAudio;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            iconSize: 36,
            icon: Icon(
              isThisPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.blue,
            ),
            onPressed: () => onToggleAudio(audioUrl!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
