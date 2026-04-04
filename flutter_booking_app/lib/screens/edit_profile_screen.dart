// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;

  File?  _newPhoto;    // newly picked photo (not yet saved)
  bool   _hasChanges = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameCtrl  = TextEditingController(text: auth.userName ?? '');
    _emailCtrl = TextEditingController(text: auth.email    ?? '');
    _phoneCtrl = TextEditingController(text: auth.phone    ?? '');
    _bioCtrl   = TextEditingController(text: auth.bio      ?? '');

    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _bioCtrl]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  // ── Pick photo ────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(),
    );
    if (source == null) return;
    try {
      final img = await _picker.pickImage(
          source: source, maxWidth: 512, imageQuality: 85);
      if (img != null && mounted) {
        setState(() {
          _newPhoto   = File(img.path);
          _hasChanges = true;
        });
      }
    } catch (_) {}
  }

  // ── Save all ──────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final ok = await auth.updateProfile(
      name:      _nameCtrl.text,
      email:     _emailCtrl.text,
      phone:     _phoneCtrl.text,
      bio:       _bioCtrl.text,
      photoPath: _newPhoto?.path, // ← saves new photo path if picked
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Profile updated!',
              style: TextStyle(fontFamily: 'Inter',
                  fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to update profile'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, auth, __) {
      // Show new picked photo first, then existing saved photo, then initials
      final photoPath  = _newPhoto?.path ?? auth.photoPath;
      final initial    = (auth.userName ?? 'U')[0].toUpperCase();

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation:       0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Edit Profile', style: TextStyle(
              fontFamily: 'Inter', fontSize: 18,
              fontWeight: FontWeight.w700, color: AppColors.textDark)),
          centerTitle: true,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: auth.isLoading ? null : _save,
                child: auth.isLoading
                    ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                    : const Text('Save', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Avatar — tappable to change ────────────────
                Center(child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(children: [
                    // Circle avatar
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryLight, width: 3),
                      ),
                      child: ClipOval(
                        child: photoPath != null
                        // Real photo
                            ? Image.file(File(photoPath),
                            fit: BoxFit.cover,
                            width: 100, height: 100,
                            errorBuilder: (_, __, ___) =>
                                _initialsAvatar(initial))
                        // Initials fallback
                            : _initialsAvatar(initial),
                      ),
                    ),
                    // Camera badge
                    Positioned(right: 0, bottom: 0,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.35),
                              blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ]),
                )),

                // "Tap to change" hint
                const SizedBox(height: 8),
                const Center(child: Text('Tap to change photo',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: AppColors.textLight))),

                const SizedBox(height: 28),

                // ── Personal Information ────────────────────────
                _sectionLabel('Personal Information'),
                const SizedBox(height: 12),
                _buildCard(children: [
                  _buildField(
                    controller: _nameCtrl,
                    label:      'Full Name',
                    icon:       Icons.person_outline,
                    validator:  (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required' : null,
                  ),
                  _divider(),
                  _buildField(
                    controller:  _emailCtrl,
                    label:       'Email Address',
                    icon:        Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator:   (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email is required';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                          .hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  _divider(),
                  _buildField(
                    controller:  _phoneCtrl,
                    label:       'Phone Number',
                    icon:        Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Bio ─────────────────────────────────────────
                _sectionLabel('About'),
                const SizedBox(height: 12),
                _buildCard(children: [
                  _buildField(
                    controller: _bioCtrl,
                    label:      'Bio',
                    icon:       Icons.notes_outlined,
                    maxLines:   3,
                    hint:       'Tell us a little about yourself...',
                  ),
                ]),
                const SizedBox(height: 32),

                // ── Save button ─────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                        : const Text('Save Changes', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _initialsAvatar(String initial) {
    return Container(
      color: AppColors.primary,
      child: Center(child: Text(initial, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 38,
        fontWeight: FontWeight.w700, color: Colors.white,
      ))),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted, letterSpacing: 0.5));
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 56, color: AppColors.cardBorder);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 16 : 0),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(
            controller:   controller,
            keyboardType: keyboardType,
            maxLines:     maxLines,
            validator:    validator,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                color: AppColors.textDark),
            decoration: InputDecoration(
              labelText:  label,
              hintText:   hint,
              labelStyle: const TextStyle(fontFamily: 'Inter',
                  fontSize: 13, color: AppColors.textMuted),
              hintStyle:  const TextStyle(fontFamily: 'Inter',
                  fontSize: 13, color: AppColors.textLight),
              border:             InputBorder.none,
              enabledBorder:      InputBorder.none,
              focusedBorder:      InputBorder.none,
              errorBorder:        InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          )),
        ],
      ),
    );
  }
}

// ── Image source bottom sheet ─────────────────────────────────
class _SourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(99))),
        const SizedBox(height: 16),
        const Text('Change Profile Photo', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16,
            fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 14),
        _tile(context, Icons.camera_alt_rounded,
            'Take Photo', ImageSource.camera),
        const SizedBox(height: 10),
        _tile(context, Icons.photo_library_rounded,
            'Choose from Gallery', ImageSource.gallery),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String label,
      ImageSource source) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, source),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 18)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFF111827))),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF), size: 18),
        ]),
      ),
    );
  }
}