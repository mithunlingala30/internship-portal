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
import 'login_screen.dart';

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
  bool _isSidebarExpanded = true; // For desktop
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  StreamSubscription? _noteSubscription;
  StreamSubscription? _clickSubscription;
  final Set<String> _shownNoteIds = {};
  final DateTime _appStartTime = DateTime.now();

  void toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

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

  Widget _buildMobileNav() {
    return Container(
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
    );
  }

  Widget _buildDesktopSidebar() {
    final bool isExpanded = _isSidebarExpanded;
    final double width = isExpanded ? 280 : 80;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          // Brand Logo Section
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'master_4k.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1.0,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MEVONICS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'LMS PORTAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned(
                            left: 16,
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive ? AppColors.primary : AppColors.textLight,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            left: 56,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isExpanded ? 1.0 : 0.0,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          if (isActive && isExpanded)
                            Positioned(
                              right: 12,
                              child: Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Profile Card at Bottom
          if (_user != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: isExpanded ? 130 : 60,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                    InkWell(
                      onTap: () => setState(() => _currentIndex = 4),
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              image: _user!.profileImageUrl != null
                                  ? DecorationImage(image: NetworkImage(_user!.profileImageUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _user!.profileImageUrl == null
                                ? Center(child: Text(_user!.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))
                                : null,
                          ),
                          Positioned(
                            left: 50,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isExpanded ? 1.0 : 0.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user!.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _user!.role.toUpperCase(),
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isExpanded ? 1.0 : 0.0,
                          child: InkWell(
                            onTap: () async {
                              await AuthService().signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                child: Row(
                                  children: [
                                    Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await AuthService().signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          icon: Icon(Icons.logout_rounded, color: AppColors.error.withValues(alpha: 0.8), size: 18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _getScreens(bool isDesktop) {
    final VoidCallback menuAction = isDesktop ? toggleSidebar : openDrawer;
    final isMentor = _user?.role == 'mentor';
    return [
      HomeScreen(onMenuPressed: menuAction),
      const CoursesScreen(),
      const ChatScreen(),
      isMentor ? const AttendanceCoursesScreen() : const ProgressScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        final screens = _getScreens(isDesktop);

        final contentBody = Container(
          color: AppColors.background,
          child: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        );

        if (isDesktop) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.surface,
            body: Row(
              children: [
                _buildDesktopSidebar(),
                Expanded(child: contentBody),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            width: 280,
            child: _buildDesktopSidebar(),
          ),
          body: contentBody,
          bottomNavigationBar: _buildMobileNav(),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
