import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MateriQuizPage extends StatefulWidget {
  final String levelId;
  const MateriQuizPage({super.key, required this.levelId});

  @override
  State<MateriQuizPage> createState() => _MateriQuizPageState();
}

class _MateriQuizPageState extends State<MateriQuizPage> {
  bool _loading = true;
  List<dynamic> _materiList = [];
  List<dynamic> _questions = [];

  int _materiIndex = 0;
  int _quizIndex = 0;
  int _score = 0;
  bool _showQuiz = false;

  // NEW: simpan jawaban user untuk setiap quiz
  final List<Map<String, dynamic>> _answers = []; // { 'quiz_id': '...', 'selected': '...' }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final materi = await supabase
          .from('materi')
          .select('materi_id, judul, isi, urutan')
          .eq('level_id', widget.levelId)
          .order('urutan');

      final quiz = await supabase
          .from('quiz')
          .select('quiz_id, tipe, pilihan, jawaban, pertanyaan')
          .eq('level_id', widget.levelId)
          .order('urutan');

      setState(() {
        _materiList = materi;
        _questions = quiz;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => _loading = false);
    }
  }

  void _nextMateri() {
    if (_materiIndex < _materiList.length - 1) {
      setState(() => _materiIndex++);
    } else {
      // Pindah ke quiz
      setState(() => _showQuiz = true);
    }
  }

  // NEW helper: record answer into _answers, also update local _score for immediate UX
  void _recordAnswer(String quizId, String selected) {
    final idx = _answers.indexWhere((e) => e['quiz_id'] == quizId);
    if (idx >= 0) {
      _answers[idx]['selected'] = selected;
    } else {
      _answers.add({'quiz_id': quizId, 'selected': selected});
    }
  }

  void _answerQuiz(String selected) {
    final current = _questions[_quizIndex];
    final quizId = current['quiz_id'] as String;
    final correct = current['jawaban'] as String?;

    // record user choice
    _recordAnswer(quizId, selected);

    // update local score for immediate feedback (optional, server will verify)
    if (correct != null && selected.trim().toLowerCase() == correct.trim().toLowerCase()) {
      _score++;
    }

    if (_quizIndex < _questions.length - 1) {
      setState(() => _quizIndex++);
    } else {
      _onQuizFinished();
    }
  }

  // NEW: send answers to server-side RPC to verify & upsert best
Future<void> _sendAnswersToServer() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  // saat kirim jawaban akhir:
  final res = await supabase.rpc('record_and_verify_best', params: {
    'p_level_id': widget.levelId,
    'p_answers': _answers,   // <--- langsung List<Map>, jangan jsonEncode
    'p_user_id': userId,     // opsional, tapi aman
  });

  // res biasanya Map<String,dynamic> yang mengandung action/score
  debugPrint('RPC result: $res');
  return res;
}

  void _showResultPopup(int score, int total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hasil Quiz"),
        content: Text("Skor kamu: $score / $total"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, true); // return true to parent so it can refresh
            },
            child: const Text("Selesai"),
          ),
        ],
      ),
    );
  }

  Future<void> _onQuizFinished() async {
    try {
      await _sendAnswersToServer();
      // server telah menghitung & meng-upsert best progress
      // tampilkan hasil berdasarkan local _score (server win for actual star)
      _showResultPopup(_score, _questions.length);
    } catch (e) {
      debugPrint('Error saving/verifying answers: $e');
      // fallback: beri feedback & tetap kembali
      _showResultPopup(_score, _questions.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_showQuiz ? "Quiz" : "Materi"),
        backgroundColor: _showQuiz ? Colors.blue : Colors.orange,
      ),
      body: !_showQuiz
          ? _materiList.isEmpty
              ? const Center(child: Text("Belum ada materi"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _materiList[_materiIndex]['judul'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: SingleChildScrollView(child: Text(_materiList[_materiIndex]['isi']))),
                      ElevatedButton(
                        onPressed: _nextMateri,
                        child: Text(_materiIndex == _materiList.length - 1 ? "Mulai Quiz" : "Lanjut Materi"),
                      ),
                    ],
                  ),
                )
          : _questions.isEmpty
              ? const Center(child: Text("Belum ada soal"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Soal ${_quizIndex + 1} / ${_questions.length}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Text(_questions[_quizIndex]['pertanyaan'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ...List<String>.from(_questions[_quizIndex]['pilihan'] ?? []).map((opsi) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _answerQuiz(opsi),
                            child: Text(opsi),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}
