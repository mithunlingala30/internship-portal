import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;
  late TextEditingController _addressController;
  late TextEditingController _yearOfStudyController;
  late TextEditingController _emailController;


  late List<String> _skills;
  bool _isLoading = false;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _bioController = TextEditingController(text: widget.user.bio);
    _skillsController = TextEditingController();
    _skills = List.from(widget.user.skills);
    _profileImageUrl = widget.user.profileImageUrl;
    _addressController = TextEditingController(text: widget.user.address);
    _yearOfStudyController = TextEditingController(text: widget.user.yearOfStudy);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _addressController.dispose();
    _yearOfStudyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final storage = StorageService();
      final url = await storage.uploadFile(
        path: 'profiles/${widget.user.id}.jpg',
        file: File(image.path),
      );
      if (url != null) {
        setState(() => _profileImageUrl = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final avatarInitials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    try {
      final updatedUser = UserModel(
        id: widget.user.id,
        name: name,
        email: _emailController.text.trim(),
        role: widget.user.role,
        avatarInitials: avatarInitials,
        completedModules: widget.user.completedModules,
        totalModules: widget.user.totalModules,
        streakDays: widget.user.streakDays,
        overallProgress: widget.user.overallProgress,
        phoneNumber: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
        profileImageUrl: _profileImageUrl,
        isNotificationsEnabled: widget.user.isNotificationsEnabled,
        fcmToken: widget.user.fcmToken,
        address: _addressController.text.trim(),
        yearOfStudy: _yearOfStudyController.text.trim(),
      );

      await FirestoreService().updateUserModel(updatedUser);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addSkill() {
    final skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: _saveProfile,
                    child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        image: _profileImageUrl != null
                            ? DecorationImage(image: NetworkImage(_profileImageUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _profileImageUrl == null
                          ? Center(
                              child: Text(
                                widget.user.avatarInitials,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 32),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Personal Details'),
            _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
            _buildTextField(label: 'Email Address', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, enabled: false),
            _buildTextField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            _buildTextField(label: 'Address', controller: _addressController, icon: Icons.location_on_outlined),
            if (widget.user.role == 'intern')
              _buildTextField(label: 'Year of Study', controller: _yearOfStudyController, icon: Icons.school_outlined),
            
            const SizedBox(height: 24),
            _buildSectionTitle('About Me'),
            _buildTextField(label: 'Bio', controller: _bioController, icon: Icons.article_outlined, maxLines: 3),
            
            const SizedBox(height: 24),


            
            const SizedBox(height: 24),
            _buildSectionTitle('Skills'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Add Skill',
                    controller: _skillsController,
                    icon: Icons.psychology_outlined,
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() => _skills.remove(skill));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    Function(String)? onFieldSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              enabled: enabled,
              keyboardType: keyboardType,
              onSubmitted: onFieldSubmitted,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
