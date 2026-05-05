import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../widgets/course_card.dart';
import '../widgets/stats_card.dart';
import 'course_detail_screen.dart';
import 'courses_screen.dart';
import 'attendance_courses_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  const HomeScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final db = FirestoreService();

    if (uid == null) return const Center(child: Text('Not logged in'));

    return StreamBuilder<UserModel?>(
        stream: db.getUserModel(uid),
        builder: (context, userSnap) {
          if (!userSnap.hasData || userSnap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnap.data!;

          return StreamBuilder<List<CourseModel>>(
              stream: db.courses,
              builder: (context, courseSnap) {
                final rawCourses = courseSnap.data ?? [];
                // Sort by date (descending) and take latest 5
                final allCourses = [...rawCourses]..sort((a, b) =>
                    (b.createdAt ?? DateTime(2000))
                        .compareTo(a.createdAt ?? DateTime(2000)));
                final displayCourses = allCourses.take(5).toList();

                final enrolledCourses = rawCourses
                    .where((c) => c.enrolledStudentIds.contains(uid))
                    .toList();
                final mentorCoursesCount =
                    allCourses.where((c) => c.mentorId == uid).length;

                return Scaffold(
                        backgroundColor: AppColors.background,
                        body: CustomScrollView(
                          slivers: [
                            // Header
                            SliverToBoxAdapter(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top + 16,
                                  left: MediaQuery.of(context).size.width > 800
                                      ? 40
                                      : 20,
                                  right: MediaQuery.of(context).size.width > 800
                                      ? 40
                                      : 20,
                                  bottom: 30,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 1000),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Avatar
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image:
                                                    user.profileImageUrl != null
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                                user.profileImageUrl!),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: user.profileImageUrl ==
                                                      null
                                                  ? Center(
                                                      child: Text(
                                                        user.avatarInitials,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Welcome back 👋',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    user.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: onMenuPressed,
                                              icon: const Icon(
                                                Icons.menu_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 20)),

                            // Stats Row
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1000),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) =>
                                                    const CoursesScreen(),
                                              ));
                                            },
                                            child: StatsCard(
                                              label: 'Total Available',
                                              value: '${allCourses.length}',
                                              icon: Icons.grid_view_rounded,
                                              gradient: AppColors.cardGradient1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (user.role == 'mentor') {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AttendanceCoursesScreen(),
                                                ));
                                              } else {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CoursesScreen(
                                                          onlyEnrolled: true),
                                                ));
                                              }
                                            },
                                            child: StatsCard(
                                              label: user.role == 'mentor'
                                                  ? 'Course Attendance'
                                                  : 'Enrolled Courses',
                                              value: user.role == 'mentor'
                                                  ? '$mentorCoursesCount'
                                                  : '${enrolledCourses.length}',
                                              icon: user.role == 'mentor'
                                                  ? Icons.how_to_reg_rounded
                                                  : Icons.menu_book_rounded,
                                              gradient: AppColors.cardGradient2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 24)),

                            // Continue Learning
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1000),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Available Courses',
                                            style: AppTextStyles.heading3),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  const CoursesScreen(),
                                            ));
                                          },
                                          child: const Text('See all',
                                              style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 12)),
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1000),
                                  child: SizedBox(
                                    height: 280,
                                    child: displayCourses.isEmpty
                                        ? const Center(
                                            child: Text('No courses available'))
                                        : ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            itemCount: displayCourses.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 14),
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (_) =>
                                                        CourseDetailScreen(
                                                            course:
                                                                displayCourses[
                                                                    index]),
                                                  ));
                                                },
                                                child: CourseCardHorizontal(
                                                    course:
                                                        displayCourses[index]),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 24)),
                          ],
                        ),
                      );
              });
        });
  }
}
