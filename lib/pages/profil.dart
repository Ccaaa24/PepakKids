import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

final supabase = Supabase.instance.client;

// Profile Theme Constants - konsisten dengan app theme
class ProfileTheme {
  static const Color backgroundStart = Color(0xFFF5E6D3);
  static const Color backgroundEnd = Color(0xFFE8D5C4);
  static const Color primaryBrown = Color(0xFFA97142);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2C1810);
  static const Color textSecondary = Color(0xFF8B6F47);
  static const Color trophyGold = Color(0xFFFFD700);
  static const Color logoutRed = Color(0xFFFF4757);
  
  static const double borderRadius = 20.0;
  static const double cardPadding = 16.0;
  static const double defaultSpacing = 20.0;
  static const double smallSpacing = 12.0;
  
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _uploadingAvatar = false;

  Future<void> _changeAvatar() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _uploadingAvatar = true);

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Read file as bytes - compatible with web and mobile
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$fileName';

      // Upload to Supabase Storage
      await supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update user profile in database
      await supabase.from('users').update({
        'avatar': publicUrl,
      }).eq('user_id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar berhasil diubah!')),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      debugPrint('Error changing avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah avatar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      // Fetch user profile data
      final userResponse = await supabase
          .from('users')
          .select('user_id, nama, avatar, total_stars')
          .eq('user_id', user.id)
          .single();

      // Fetch additional stats (progress data untuk total stars)
      final progressResponse = await supabase
          .from('progress')
          .select('star_earned')
          .eq('user_id', user.id);

      // Calculate total stars
      int totalStars = 0;
      if (progressResponse.isNotEmpty) {
        for (var progress in progressResponse) {
          totalStars += (progress['star_earned'] as int? ?? 0);
        }
      }

      return {
        ...userResponse,
        'calculated_stars': totalStars,
        'email': user.email ?? 'No email',
      };
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProfileTheme.backgroundStart,
              ProfileTheme.backgroundEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern dengan safe loading
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_pattern_kids.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.1),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Background asset failed to load: $error');
                  return Container(); // Transparent fallback
                },
              ),
            ),
            // Main content
            SafeArea(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _fetchProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ProfileTheme.primaryBrown),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    debugPrint('Profile error: ${snapshot.error}');
                    final dummyData = {
                      'nama': 'User',
                      'avatar': 'https://via.placeholder.com/150',
                      'calculated_stars': 0,
                    };
                    return _buildProfileContent(dummyData);
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    debugPrint('No profile data found');
                    final dummyData = {
                      'nama': 'User',
                      'avatar': 'https://via.placeholder.com/150',
                      'calculated_stars': 0,
                    };
                    return _buildProfileContent(dummyData);
                  }

                  final data = snapshot.data!;
                  debugPrint('Profile data loaded: $data');
                  return _buildProfileContent(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> data) {
    final nama = data['nama'] ?? "Tanpa Nama";
    final avatar = data['avatar'] ?? "https://via.placeholder.com/150";
    final totalStars = data['calculated_stars'] ?? 0;

    debugPrint('Building profile content for: $nama, stars: $totalStars');

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 600;
        
        return Column(
          children: [
            // Header dengan back button - Fixed height
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ProfileTheme.defaultSpacing,
                vertical: ProfileTheme.smallSpacing,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: ProfileTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    "Kembali",
                    style: TextStyle(
                      color: ProfileTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content area - Flexible untuk mengisi sisa ruang
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileTheme.defaultSpacing,
                ),
                child: Column(
                  children: [
                    // Avatar Section
                    _buildResponsiveAvatarSection(nama, avatar, isSmallScreen),
                    SizedBox(height: ProfileTheme.defaultSpacing),

                    // Stats Card (hanya Bintang)
                    _buildResponsiveStatsCards(totalStars),
                    SizedBox(height: ProfileTheme.defaultSpacing),

                    // Menu Items
                    _buildResponsiveMenuItems(),
                    SizedBox(height: ProfileTheme.defaultSpacing),
                    
                    // Logout Button
                    _buildLogoutButton(),
                    SizedBox(height: ProfileTheme.defaultSpacing),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveAvatarSection(String nama, String avatar, bool isSmallScreen) {
    debugPrint('Building avatar section for: $nama');
    final avatarRadius = isSmallScreen ? 50.0 : 60.0;
    final nameSize = isSmallScreen ? 20.0 : 24.0;
    
    return Column(
      children: [
        // Avatar dengan border putih dan edit button
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [ProfileTheme.cardShadow],
              ),
              child: _uploadingAvatar
                  ? CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey[300],
                      child: const CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: NetworkImage(avatar),
                      backgroundColor: Colors.grey[300],
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle image load error
                      },
                      child: avatar.contains('placeholder')
                          ? Icon(Icons.person, size: avatarRadius, color: Colors.grey)
                          : null,
                    ),
            ),
            // Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _uploadingAvatar ? null : _changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ProfileTheme.primaryBrown,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [ProfileTheme.cardShadow],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 8 : ProfileTheme.smallSpacing),

        // Nama (tanpa badge Beginner)
        Text(
          nama,
          style: TextStyle(
            fontSize: nameSize,
            fontWeight: FontWeight.bold,
            color: ProfileTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }


  Widget _buildResponsiveStatsCards(int totalStars) {
    debugPrint('Building stats card: stars=$totalStars');
    
    // Hitung level berdasarkan completed levels
    return FutureBuilder<int>(
      future: _getCompletedLevelsCount(),
      builder: (context, snapshot) {
        final completedLevels = snapshot.data ?? 0;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bintang Card
            Expanded(
              child: _buildResponsiveStatCard(
                "$totalStars", 
                "Bintang", 
                Icons.star, 
                ProfileTheme.trophyGold,
                false,
              ),
            ),
            const SizedBox(width: 16),
            // Level Card
            Expanded(
              child: _buildResponsiveStatCard(
                "$completedLevels", 
                "Level", 
                Icons.emoji_events, 
                Colors.red,
                false,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int> _getCompletedLevelsCount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return 0;

      final progressResponse = await supabase
          .from('progress')
          .select('star_earned')
          .eq('user_id', user.id);

      // Hitung level yang sudah dikerjakan (star > 0)
      int completedLevels = 0;
      for (var progress in progressResponse) {
        final stars = progress['star_earned'] as int? ?? 0;
        if (stars > 0) {
          completedLevels++;
        }
      }
      
      return completedLevels;
    } catch (e) {
      debugPrint('Error getting completed levels: $e');
      return 0;
    }
  }


  Widget _buildResponsiveStatCard(String value, String label, IconData icon, Color iconColor, bool isNarrow) {
    final valueSize = isNarrow ? 24.0 : 32.0;
    final labelSize = isNarrow ? 12.0 : 14.0;
    final cardPadding = isNarrow ? 12.0 : ProfileTheme.cardPadding;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: ProfileTheme.cardBackground,
        borderRadius: BorderRadius.circular(ProfileTheme.borderRadius),
        boxShadow: [ProfileTheme.cardShadow],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: ProfileTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                color: ProfileTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildResponsiveMenuItems() {
    debugPrint('Building responsive menu items');
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200, // Minimum height untuk menu items
      ),
      padding: const EdgeInsets.all(ProfileTheme.cardPadding),
      decoration: BoxDecoration(
        color: ProfileTheme.cardBackground,
        borderRadius: BorderRadius.circular(ProfileTheme.borderRadius),
        boxShadow: [ProfileTheme.cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItemWithSvg(
            svgAsset: "assets/icons/edit_profile_kids.svg",
            title: "Edit Profile",
            iconColor: Colors.pink,
            onTap: _showEditProfileDialog,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: "Bantuan",
            iconColor: Colors.blue,
            onTap: _showHelpDialog,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: "Tentang Aplikasi",
            iconColor: Colors.orange,
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  // Dialog Edit Profile
  void _showEditProfileDialog() {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Baru",
                  hintText: "Masukkan nama baru",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru (opsional)",
                  hintText: "Kosongkan jika tidak ingin ubah",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Konfirmasi Password",
                  hintText: "Ulangi password baru",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(
                nameController.text,
                passwordController.text,
                confirmPasswordController.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String newName, String newPassword, String confirmPassword) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Update nama jika diisi
      if (newName.isNotEmpty) {
        await supabase.from('users').update({
          'nama': newName,
        }).eq('user_id', user.id);
      }

      // Update password jika diisi
      if (newPassword.isNotEmpty) {
        if (newPassword != confirmPassword) {
          throw Exception('Password tidak cocok');
        }
        if (newPassword.length < 6) {
          throw Exception('Password minimal 6 karakter');
        }
        
        await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diupdate!')),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Dialog Bantuan
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("Bantuan"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cara Bermain:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text("1. Pilih level yang ingin kamu mainkan"),
              Text("2. Pelajari materi dengan mendengarkan audio"),
              Text("3. Kerjakan quiz untuk mendapatkan bintang"),
              Text("4. Kumpulkan 3 bintang untuk membuka level berikutnya"),
              SizedBox(height: 16),
              Text(
                "Tips:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text("• Dengarkan audio dengan seksama"),
              Text("• Ulangi materi jika perlu"),
              Text("• Kerjakan quiz dengan teliti"),
              SizedBox(height: 16),
              Text(
                "Butuh bantuan lebih lanjut?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Hubungi: support@pepakkids.com"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // Dialog Tentang Aplikasi
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text("Tentang Aplikasi"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  "PepakKids",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Versi 1.0.0",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "PepakKids adalah aplikasi pembelajaran bahasa Jawa untuk anak-anak. Belajar kosakata bahasa Jawa dengan cara yang menyenangkan!",
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text(
                "Dikembangkan oleh:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Tim PepakKids"),
              SizedBox(height: 8),
              Text(
                "© 2024 PepakKids. All rights reserved.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }



  Widget _buildMenuItemWithSvg({
    required String svgAsset,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                svgAsset,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                placeholderBuilder: (context) {
                  debugPrint('SVG placeholder for: $svgAsset');
                  return Icon(
                    _getIconForAsset(svgAsset),
                    color: iconColor,
                    size: 20,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ProfileTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ProfileTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk fallback icons
  IconData _getIconForAsset(String svgAsset) {
    if (svgAsset.contains('edit_profile')) return Icons.edit;
    if (svgAsset.contains('notification')) return Icons.notifications;
    if (svgAsset.contains('settings')) return Icons.settings;
    if (svgAsset.contains('logout')) return Icons.logout;
    return Icons.help_outline;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ProfileTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ProfileTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  // Logout function - konsisten dengan home.dart
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Keluar"),
              content: const Text("Apakah Anda yakin ingin keluar?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Keluar"),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await _logout(); // Gunakan function yang konsisten dengan home.dart
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ProfileTheme.logoutRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfileTheme.borderRadius),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/logout_door_kids.svg",
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              placeholderBuilder: (context) {
                debugPrint('SVG placeholder for logout icon');
                return const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              "KELUAR",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
