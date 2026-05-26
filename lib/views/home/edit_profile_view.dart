import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import '../../data/services/firestore_service.dart';
import '../../shared/creative_background.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late AnimationController _animController;

  Uint8List? _imageBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ── Cloudinary config ──────────────────────────────────────────────
  static const String _cloudName = 'domobmswb';
  static const String _uploadPreset = 'profile';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ── Pick image from gallery ────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Upload to Cloudinary ───────────────────────────────────────────
  Future<String?> _uploadToCloudinary(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final user = FirebaseAuth.instance.currentUser;
      final filename = '${user?.uid ?? 'profile'}.jpg';

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: filename,
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary error: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Upload Cloudinary error: $e');
      return null;
    }
  }

  // ── Save profile ───────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final firestoreService = FirestoreService();
    String? newPhotoUrl = user.photoURL;
    bool photoUploadFailed = false;

    try {
      // 1. Upload foto baru ke Cloudinary (jika ada)
      if (_imageBytes != null) {
        final uploadedUrl = await _uploadToCloudinary(_imageBytes!);
        if (uploadedUrl != null) {
          newPhotoUrl = uploadedUrl;
        } else {
          photoUploadFailed = true;
          newPhotoUrl = user.photoURL; // tetap pakai foto lama
        }
      }

      // 2. Update Firebase Auth
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty) {
        await user.updateDisplayName(newName);
      }
      if (newPhotoUrl != null && newPhotoUrl != user.photoURL) {
        await user.updatePhotoURL(newPhotoUrl);
      }

      // 3. Update Firestore users collection
      await firestoreService.updateUserProfile(
        user.uid,
        displayName: newName.isNotEmpty ? newName : null,
        photoUrl: newPhotoUrl,
      );

      if (mounted) {
        if (photoUploadFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profil disimpan, tapi foto gagal diupload. Coba lagi.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil disimpan!'),
              backgroundColor: Color(0xFF4ADE80),
            ),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Animation helper ───────────────────────────────────────────────
  Widget _buildAnimatedChild(Widget child, int index) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? 'Pengguna';

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1F12),
                  Color(0xFF0D2818),
                  Color(0xFF0F2E1A),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: StarSparkleBackground(),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AppBar ────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Avatar Section ────────────────────────────
                        _buildAnimatedChild(
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF6EE89A),
                                            width: 3),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF22C55E),
                                            Color(0xFF4ADE80)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: _imageBytes != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                _imageBytes!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : photoUrl != null
                                              ? ClipOval(
                                                  child: Image.network(
                                                    photoUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            _buildInitialAvatar(
                                                                displayName),
                                                  ),
                                                )
                                              : _buildInitialAvatar(
                                                  displayName),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ADE80),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFF0D2818),
                                                width: 3),
                                          ),
                                          child: const Icon(Icons.edit,
                                              color: Color(0xFF0D2818),
                                              size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          0,
                        ),

                        const SizedBox(height: 40),

                        _buildAnimatedChild(
                          const Text(
                            'Your Information',
                            style: TextStyle(
                              color: Color(0xFFE2E385),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          1,
                        ),

                        const SizedBox(height: 24),

                        _buildAnimatedChild(
                          _buildInputField(
                              label: 'Username', controller: _nameController),
                          2,
                        ),
                        const SizedBox(height: 20),

                        _buildAnimatedChild(
                          _buildInputField(
                              label: 'E-mail',
                              controller: _emailController,
                              isEmail: true),
                          3,
                        ),
                        const SizedBox(height: 40),

                        // ── Simpan Button ─────────────────────────────
                        _buildAnimatedChild(
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6EE89A),
                                disabledBackgroundColor:
                                    const Color(0xFF6EE89A).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0D2818),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        color: Color(0xFF0D2818),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          4,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF0D2818),
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6EE89A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF163520),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C4334)),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType:
                  isEmail ? TextInputType.emailAddress : TextInputType.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
