import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_theme.dart';
import '../widgets/result_info_card.dart';

final supabase = Supabase.instance.client;

// Result Page - Standalone page untuk menampilkan hasil quiz
class ResultPage extends StatefulWidget {
  final String levelId;
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> answers; // List jawaban user
  
  const ResultPage({
    super.key,
    required this.levelId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  int _starsEarned = 0;
  bool _loading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _sendAnswersAndGetStars();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Send answers to server-side RPC to verify & upsert best
  Future<void> _sendAnswersAndGetStars() async {
    try {
      final result = await _sendAnswersToServer();
      // Extract stars earned from server response
      if (result != null) {
        _starsEarned = result['stars_earned'] ?? _calculateLocalStars();
      } else {
        _starsEarned = _calculateLocalStars();
      }
    } catch (e) {
      debugPrint('Error saving/verifying answers: $e');
      // fallback: gunakan kalkulasi lokal untuk stars
      _starsEarned = _calculateLocalStars();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _animationController.forward();
      }
    }
  }

  Future<Map<String, dynamic>?> _sendAnswersToServer() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Format answers untuk backend (hanya quiz_id dan selected)
      final formattedAnswers = widget.answers.map((answer) => {
        'quiz_id': answer['quiz_id'],
        'selected': answer['selected'],
      }).toList();

      debugPrint('🚀 Sending answers to server: $formattedAnswers');
      debugPrint('📊 Local score: ${widget.score}/${widget.totalQuestions}');

      final res = await supabase.rpc('record_and_verify_best', params: {
        'p_level_id': widget.levelId,
        'p_answers': formattedAnswers,
        'p_user_id': userId,
      });

      debugPrint('✅ RPC result: $res');
      return res is Map<String, dynamic> ? res : null;
    } catch (e) {
      debugPrint('❌ Error in _sendAnswersToServer: $e');
      return null;
    }
  }

  // Kalkulasi bintang berdasarkan skor lokal
  int _calculateLocalStars() {
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    if (percentage >= 90) return 3; // ⭐⭐⭐
    if (percentage >= 70) return 2; // ⭐⭐
    if (percentage >= 50) return 1; // ⭐
    return 0; // Tidak ada bintang
  }

  void _retryQuiz() {
    // Pop result page dan kembali ke quiz
    Navigator.pop(context, {'action': 'retry'});
  }
  
  void _backToMateri() {
    // Pop result page dan kembali ke materi
    Navigator.pop(context, {'action': 'back_to_materi'});
  }
  
  void _finishAndExit() {
    // Pop result page dan keluar
    Navigator.pop(context, {'action': 'finish', 'refresh': true});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFF5F0E8),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                ),
                SizedBox(height: 16),
                Text(
                  'Menyimpan hasil...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
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
                  onPressed: _finishAndExit,
                  icon: const Icon(Icons.arrow_back, size: 28, color: Color(0xFF5D4E37)),
                ),
              ),
              
              // Result content
              _buildResultContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    final correctAnswers = widget.score;
    final wrongAnswers = widget.totalQuestions - widget.score;
    final isLevelUnlocked = _starsEarned >= 3;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.defaultSpacing),
      child: Column(
        children: [
          const SizedBox(height: 40), // Space for back button
          
          // Stars Display - Big and centered
          FadeTransition(
            opacity: _animationController,
            child: _buildBigStarsDisplay(_starsEarned),
          ),
          const SizedBox(height: 16),

          // Success Message
          if (isLevelUnlocked) ...[
            const Text(
              "KERJA BAGUS !",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4E37),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Level Baru dibuka",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8B6F47),
              ),
            ),
          ] else ...[
            const Text(
              "KERJA BAGUS !",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4E37),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Level Info Card
          FutureBuilder<String>(
            future: _getLevelName(),
            builder: (context, snapshot) {
              final levelName = snapshot.data ?? "Level";
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: Text(
                  levelName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Stats Cards
          ResultInfoCard(
            label: "Quiz Benar",
            value: "$correctAnswers/${widget.totalQuestions}",
            backgroundColor: const Color(0xFFE3F2FD), // Light blue
            textColor: const Color(0xFF2196F3), // Blue
          ),
          const SizedBox(height: 12),
          
          ResultInfoCard(
            label: "Quiz Salah",
            value: "$wrongAnswers/${widget.totalQuestions}",
            backgroundColor: const Color(0xFFFFEBEE), // Light red/pink
            textColor: const Color(0xFFE57373), // Red
          ),
          const SizedBox(height: 32),

          // Kembali Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishAndExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Kembali",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<String> _getLevelName() async {
    try {
      final levelData = await supabase
          .from('level')
          .select('nama_level')
          .eq('level_id', widget.levelId)
          .single();
      
      return levelData['nama_level'] ?? "Level";
    } catch (e) {
      debugPrint('Error getting level name: $e');
      return "Level";
    }
  }

  Widget _buildBigStarsDisplay(int starsEarned) {
    const int maxStars = 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        final isEarned = index < starsEarned;
        final delay = index * 200;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay / 1500,
                  (delay + 500) / 1500,
                  curve: Curves.elasticOut,
                ),
              ),
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isEarned
                    ? const LinearGradient(
                        colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEarned ? null : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: isEarned
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isEarned ? Icons.star : Icons.star_border,
                color: isEarned ? Colors.white : Colors.grey[400],
                size: 50,
              ),
            ),
          ),
        );
      }),
    );
  }

}
