import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pepakkids/pages/quiz.dart';
import '../widgets/content_card.dart';
import '../widgets/button_putih.dart';
import '../widgets/button_coklat.dart';

final supabase = Supabase.instance.client;

// Materi Page - Standalone page untuk materi
class MateriPage extends StatefulWidget {
  final String levelId;
  
  const MateriPage({
    super.key,
    required this.levelId,
  });

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  bool _loading = true;
  List<dynamic> _materiList = [];
  int _materiIndex = 0;

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
      final materi = await supabase
          .from('materi')
          .select('materi_id, judul, isi, urutan, materi_aset(aset(url, jenis))')
          .eq('level_id', widget.levelId)
          .order('urutan');

      setState(() {
        _materiList = materi;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching materi: $e");
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

  void _nextMateri() async {
    await _stopAudio();
    
    if (_materiIndex < _materiList.length - 1) {
      setState(() => _materiIndex++);
    } else {
      // Pindah ke quiz
      if (!mounted) return;
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPage(levelId: widget.levelId),
        ),
      );

      // Handle result from quiz
      if (result != null && result is Map<String, dynamic>) {
        final action = result['action'];
        if (action == 'back_to_materi') {
          // Reset to first materi
          setState(() {
            _materiIndex = 0;
          });
        } else if (action == 'finish') {
          if (mounted) {
            Navigator.pop(context, result['refresh'] ?? false);
          }
        }
      } else if (result == true) {
        // Simple refresh flag
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  void _previousMateri() {
    if (_materiIndex > 0) {
      setState(() => _materiIndex--);
    }
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

    if (_materiList.isEmpty) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFF5F0E8),
          child: const Center(
            child: Text("Belum ada materi"),
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
              
              // Materi content
              MateriCard(
                materiList: _materiList,
                materiIndex: _materiIndex,
                onNext: _nextMateri,
                onPrevious: _previousMateri,
                audioPlayer: _audioPlayer,
                currentAudioUrl: _currentAudioUrl,
                isPlayingAudio: _isPlayingAudio,
                onToggleAudio: _togglePlayForUrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Materi Card Widget - Redesigned based on new UI
class MateriCard extends StatelessWidget {
  final List<dynamic> materiList;
  final int materiIndex;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final AudioPlayer audioPlayer;
  final String? currentAudioUrl;
  final bool isPlayingAudio;
  final Function(String) onToggleAudio;

  const MateriCard({
    super.key,
    required this.materiList,
    required this.materiIndex,
    required this.onNext,
    required this.onPrevious,
    required this.audioPlayer,
    required this.currentAudioUrl,
    required this.isPlayingAudio,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    if (materiList.isEmpty) {
      return const Center(child: Text("Belum ada materi"));
    }

    final materi = materiList[materiIndex];
    final judul = materi['judul'] ?? '';
    final isi = materi['isi'] ?? '';
    final asetList = materi['materi_aset'] as List<dynamic>?;
    
    // Get image and audio URLs
    String? imageUrl;
    String? audioUrl;
    
    if (asetList != null && asetList.isNotEmpty) {
      for (final item in asetList) {
        final aset = item['aset'] as Map<String, dynamic>?;
        final jenis = aset?['jenis'] as String?;
        
        if (aset != null && jenis != null) {
          if (jenis.toLowerCase().contains('gambar') || jenis.toLowerCase().contains('image')) {
            imageUrl = aset['url'] as String?;
          } else if (jenis.toLowerCase().contains('audio')) {
            audioUrl = aset['url'] as String?;
          }
        }
      }
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
                    value: (materiIndex + 1) / materiList.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Main card with image/word - Using ContentCard widget
                ContentCard(
                  title: judul,
                  subtitle: isi.isNotEmpty ? isi : null,
                  imageUrl: imageUrl,
                  backgroundColor: const Color(0xFFFFC107),
                ),
                const SizedBox(height: 24),
                
                // Instruction text
                const Text(
                  "Tekan untuk mulai mendegarkan\ncara pengejaan nya",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B6F47),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Audio button
                _buildAudioButton(audioUrl),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        
        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Kembali button (only show if not first page)
              if (materiIndex > 0) ...[
                Expanded(
                  child: ButtonPutih(
                    text: "Kembali",
                    onPressed: onPrevious,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Lanjut button
              Expanded(
                flex: materiIndex > 0 ? 1 : 2,
                child: ButtonCoklat(
                  text: materiIndex == materiList.length - 1 ? "Mulai Quiz" : "Lanjut",
                  onPressed: onNext,
                  height: 56,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioButton(String? audioUrl) {
    if (audioUrl == null) {
      // No audio available
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[400]!,
            width: 3,
          ),
        ),
        child: Icon(
          Icons.volume_off,
          size: 36,
          color: Colors.grey[400],
        ),
      );
    }

    final isThisPlaying = (currentAudioUrl == audioUrl) && isPlayingAudio;

    return GestureDetector(
      onTap: () => onToggleAudio(audioUrl),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFA37B58),
            width: 3,
          ),
          color: Colors.white,
        ),
        child: Icon(
          isThisPlaying ? Icons.pause : Icons.volume_up,
          size: 36,
          color: const Color(0xFFA37B58),
        ),
      ),
    );
  }
}
