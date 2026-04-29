import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'academic_records_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final db = FirestoreService();
    final auth = AuthService();

    if (uid == null) return const Center(child: Text('Not logged in'));

    return StreamBuilder<UserModel?>(
      stream: db.getUserModel(uid),
      builder: (context, userSnap) {
        if (!userSnap.hasData || userSnap.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = userSnap.data!;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Stack(
                  children: [
                    Container(
                      height: 320,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.15,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: Image.asset('master_4k.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Profile',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Avatar logic
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                image: user.profileImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(user.profileImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: user.profileImageUrl == null
                                  ? Center(
                                      child: Text(
                                        user.avatarInitials,
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 28),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(user.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _TagChip(
                                    label: user.role.toUpperCase(),
                                    color: Colors.white.withValues(alpha: 0.3)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            if (user.phoneNumber.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone_rounded, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (user.address.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.address,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (user.role == 'intern' && user.yearOfStudy.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.school_outlined, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Year of Study: ${user.yearOfStudy}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (user.bio.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('About Me', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(user.bio,
                              style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (user.skills.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: AppDecorations.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology_outlined, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Skills', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.skills.map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                              ),
                              child: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],


                // Settings List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: AppDecorations.cardDecoration,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.person_rounded,
                          label: 'Personal Information',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                        ),
                        _divider(),
                        _SettingsTile(
                          icon: Icons.history_edu_rounded,
                          label: 'Academic Records',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AcademicRecordsScreen(user: user))),
                        ),
                        _divider(),
                        _SettingsTile(
                          icon: Icons.notifications_rounded,
                          label: 'Notifications',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen(userId: uid))),
                        ),
                        _divider(),
                        _SettingsTile(
                          icon: Icons.lock_rounded,
                          label: 'Change Password',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                        ),
                        _divider(),
                        _SettingsTile(icon: Icons.help_rounded, label: 'Help & Support', onTap: () {}),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: AppDecorations.cardDecoration,
                    child: _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      color: AppColors.error,
                      onTap: () async {
                        await auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Mevonics LMS Portal v1.0.0', style: AppTextStyles.caption),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, color: AppColors.divider);
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _TagChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}


class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 18),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
    );
  }
}
