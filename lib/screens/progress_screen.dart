import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final db = FirestoreService();

    if (uid == null) return const Center(child: Text('Not logged in'));

    return StreamBuilder<List<CourseModel>>(
      stream: db.courses,
      builder: (context, courseSnap) {
        final allCourses = courseSnap.data ?? [];
        final enrolledCourses =
            allCourses.where((c) => c.enrolledStudentIds.contains(uid)).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: AppColors.primary,
                floating: true,
                pinned: true,
                snap: false,
                elevation: 0,
                expandedHeight: 240,
                centerTitle: false,
                iconTheme: const IconThemeData(color: Colors.white),
                title: innerBoxIsScrolled
                    ? const Text('My Progress',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Header Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          image: const DecorationImage(
                            image: AssetImage('master_4k.png'),
                            fit: BoxFit.cover,
                            opacity: 0.4,
                          ),
                        ),
                      ),
                      // Overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      // Content
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            MediaQuery.of(context).padding.top + 45,
                            20,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'My Learning Progress',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Real-time attendance & course stats',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _HeaderStat(
                                    label: 'Enrolled',
                                    value: '${enrolledCourses.length}',
                                    icon: Icons.menu_book_rounded,
                                    color: Colors.blue.shade300,
                                  ),
                                  const SizedBox(width: 12),
                                  _HeaderStat(
                                    label: 'Ongoing',
                                    value: '${enrolledCourses.where((c) => c.status == 'ongoing').length}',
                                    icon: Icons.play_circle_rounded,
                                    color: Colors.orange.shade300,
                                  ),
                                  const SizedBox(width: 12),
                                  _HeaderStat(
                                    label: 'Complete',
                                    value: '${enrolledCourses.where((c) => c.status == 'finished').length}',
                                    icon: Icons.check_circle_rounded,
                                    color: Colors.green.shade300,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: enrolledCourses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 52, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text('No enrolled courses yet.',
                            style: AppTextStyles.body),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                    itemCount: enrolledCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final course = enrolledCourses[index];
                      return _AttendanceCard(
                        course: course,
                        uid: uid,
                        db: db,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

// ── Header stat bubble ──────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _HeaderStat(
      {required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Per-course attendance card ──────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final CourseModel course;
  final String uid;
  final FirestoreService db;
  const _AttendanceCard(
      {required this.course, required this.uid, required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttendanceModel?>(
      stream: db.getAttendance(course.id, uid),
      builder: (context, snap) {
        final attendance = snap.data;
        final total = attendance?.totalSessions ?? 0;
        final attended = attendance?.attendedSessions ?? 0;
        final percent = total == 0 ? 0.0 : attended / total;
        final percentInt = (percent * 100).toInt();

        final gradient = _gradient(course.gradientIndex);
        final barColor = gradient.colors.first;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + title + badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(course.category,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _percentColor(percentInt).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentInt%',
                      style: TextStyle(
                        color: _percentColor(percentInt),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress and Metrics
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Attendance Rate',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        Text('$percentInt%',
                            style: TextStyle(
                                color: _percentColor(percentInt),
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14, color: _percentColor(percentInt)),
                        const SizedBox(width: 4),
                        Text(
                          total == 0
                              ? 'No sessions recorded'
                              : '$attended of $total sessions attended',
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom row: status chip + more info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        course.status == 'finished'
                            ? 'Course Completed'
                            : 'Ongoing',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: course.status == 'finished'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.status == 'finished' ? 'FINISHED' : 'ONGOING',
                      style: TextStyle(
                        color: course.status == 'finished'
                            ? AppColors.success
                            : AppColors.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              // Warning if below 75%
              if (total > 0 && percentInt < 75) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Attendance below 75% — improve attendance',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  LinearGradient _gradient(int index) {
    const g = [
      AppColors.cardGradient1,
      AppColors.cardGradient2,
      AppColors.cardGradient3,
      AppColors.cardGradient4,
    ];
    return g[index % g.length];
  }

  Color _percentColor(int pct) {
    if (pct >= 75) return AppColors.success;
    if (pct >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
