import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'chat_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'attendance_courses_screen.dart';
import 'notifications_screen.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/local_notification_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  UserModel? _user;
  bool _isLoading = true;
  StreamSubscription? _noteSubscription;
  StreamSubscription? _clickSubscription;
  final Set<String> _shownNoteIds = {};
  final DateTime _appStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initNotificationListener();
    _listenToNotificationClicks();
  }

  void _listenToNotificationClicks() {
    _clickSubscription = LocalNotificationService.onNotificationClick.stream.listen((payload) {
      if (payload != null) {
        _handleNotificationPayload(payload);
      }
    });
  }

  void _handleNotificationPayload(String payload) {
    // Navigate to notifications screen first as requested
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => NotificationsScreen(userId: uid))
      );
    }
  }

  @override
  void dispose() {
    _noteSubscription?.cancel();
    _clickSubscription?.cancel();
    super.dispose();
  }

  void _initNotificationListener() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _noteSubscription = FirestoreService().getNotifications(uid).listen((notes) {
      final notificationsEnabled = _user?.isNotificationsEnabled ?? true;
      if (!notificationsEnabled) return;

      for (var note in notes) {
        // Only show if:
        // 1. It's unread
        // 2. It's relatively new (created within last 5 mins or after start)
        // 3. We haven't shown it yet in this session
        final isRecent = note.timestamp.isAfter(_appStartTime.subtract(const Duration(minutes: 5)));
        
        if (!note.isRead && isRecent && !_shownNoteIds.contains(note.id)) {
          _shownNoteIds.add(note.id);
          LocalNotificationService.showNotification(
            id: note.id.hashCode,
            title: note.title,
            body: note.message,
            payload: '${note.type}|${note.courseId ?? ''}|${note.id}',
          );
        }
      }
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUserModel();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
      // Request permissions when the app reaches the main shell
      LocalNotificationService.requestPermissions();
    }
  }

  List<Widget> get _screens {
    final isMentor = _user?.role == 'mentor';
    return [
      const HomeScreen(),
      const CoursesScreen(),
      const ChatScreen(),
      isMentor ? const AttendanceCoursesScreen() : const ProgressScreen(),
      const ProfileScreen(),
    ];
  }

  List<_NavItem> get _navItems {
    final isMentor = _user?.role == 'mentor';
    return [
      const _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      const _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Courses'),
      const _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat'),
      _NavItem(
        icon: isMentor ? Icons.how_to_reg_outlined : Icons.insights_outlined,
        activeIcon: isMentor ? Icons.how_to_reg_rounded : Icons.insights_rounded,
        label: isMentor ? 'Attendance' : 'Progress',
      ),
      const _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2FBE).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? AppColors.primary : AppColors.textLight,
                          size: 22,
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
