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
      setState(() => _showQuiz = true);
    }
  }

  void _answerQuiz(String selected) {
  final correct = _questions[_quizIndex]['jawaban']; // ✅ pakai 'jawaban'
  if (selected == correct) {
    _score++;
  }

  if (_quizIndex < _questions.length - 1) {
    setState(() => _quizIndex++);
  } else {
    _showResult();
  }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hasil Quiz"),
        content: Text("Skor kamu: $_score / ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // keluar ke halaman sebelumnya
            },
            child: const Text("Selesai"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(_materiList[_materiIndex]['isi']),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _nextMateri,
                        child: Text(
                          _materiIndex == _materiList.length - 1
                              ? "Mulai Quiz"
                              : "Lanjut Materi",
                        ),
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
                    Text(
                      "Soal ${_quizIndex + 1} / ${_questions.length}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _questions[_quizIndex]['pertanyaan'] ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Ambil opsi dari array `pilihan`
                    ...List<String>.from(_questions[_quizIndex]['pilihan'] ?? [])
                        .map((opsi) {
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
