import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'enrolled_students_screen.dart';
import 'create_material_screen.dart';
import 'create_assignment_screen.dart';
import 'assignment_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirestoreService _db = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;




  void _enrollCourse(CourseModel currentCourse) async {
    if (_uid == null) return;
    if (currentCourse.enrolledStudentIds.contains(_uid!)) return;
    if (currentCourse.enrollmentPendingIds.contains(_uid!)) return;

    final updatedPendings = List<String>.from(currentCourse.enrollmentPendingIds)..add(_uid!);
    final updatedCourse = CourseModel(
      id: currentCourse.id,
      courseCode: currentCourse.courseCode,
      title: currentCourse.title,
      instructor: currentCourse.instructor,
      duration: currentCourse.duration,
      totalLessons: currentCourse.totalLessons,
      completedLessons: currentCourse.completedLessons,
      rating: currentCourse.rating,
      category: currentCourse.category,
      difficulty: currentCourse.difficulty,
      isEnrolled: currentCourse.isEnrolled,
      gradientIndex: currentCourse.gradientIndex,
      lessons: currentCourse.lessons,
      liveSessions: currentCourse.liveSessions,
      enrolledStudentIds: currentCourse.enrolledStudentIds,
      enrollmentPendingIds: updatedPendings,
      mentorId: currentCourse.mentorId,
      status: currentCourse.status,
    );
    await _db.updateCourse(updatedCourse);
    
    // Create notification for mentor
    if (currentCourse.mentorId != null) {
      final student = await _db.getUserFuture(_uid!);
      await _db.createNotification(NotificationModel(
        id: '',
        receiverId: currentCourse.mentorId!,
        senderId: _uid!,
        senderName: student?.name ?? 'A student',
        title: 'Enrollment Request',
        message: '${student?.name ?? 'A student'} requested to join "${currentCourse.title}"',
        courseId: currentCourse.id,
        type: 'enrollment_request',
        timestamp: DateTime.now(),
      ));
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment request sent to mentor!')));
  }

  void _addMaterial(CourseModel course) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateMaterialScreen(course: course)));
  }

  void _addLiveSession(CourseModel currentCourse) async {
    // Simple dialog to add live session
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.videocam_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('Add Live Session', style: AppTextStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Session Title',
                prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary, size: 18),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Time  (e.g. Mon 10:00 AM)',
                prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Meeting Link',
                prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary, size: 18),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final session = LiveSessionModel(title: titleCtrl.text, time: timeCtrl.text, link: linkCtrl.text);
                final updated = CourseModel(
                  id: currentCourse.id,
                  courseCode: currentCourse.courseCode,
                  title: currentCourse.title,
                  instructor: currentCourse.instructor,
                  duration: currentCourse.duration,
                  totalLessons: currentCourse.totalLessons,
                  completedLessons: currentCourse.completedLessons,
                  rating: currentCourse.rating,
                  category: currentCourse.category,
                  difficulty: currentCourse.difficulty,
                  isEnrolled: currentCourse.isEnrolled,
                  gradientIndex: currentCourse.gradientIndex,
                  lessons: currentCourse.lessons,
                  liveSessions: [...currentCourse.liveSessions, session],
                  enrolledStudentIds: currentCourse.enrolledStudentIds,
                  enrollmentPendingIds: currentCourse.enrollmentPendingIds,
                  mentorId: currentCourse.mentorId,
                  status: currentCourse.status,
                );
                await _db.updateCourse(updated);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add Session'),
          ),
        ],
      ),
    );
  }

  void _addAssignment(CourseModel course) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAssignmentScreen(course: course)));
  }

  void _deleteCourse(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 10),
            Text('Delete Course', style: AppTextStyles.heading3),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
          style: AppTextStyles.bodySecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteCourse(course.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _finishCourse(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Text('Finish Course', style: AppTextStyles.heading3),
          ],
        ),
        content: const Text(
          'This will mark the course as completed. No more lessons can be added.',
          style: AppTextStyles.bodySecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.finishCourse(course.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course marked as finished!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return StreamBuilder<UserModel?>(
      stream: _db.getUserModel(_uid!),
      builder: (context, userSnap) {
        final isMentor = userSnap.data?.role == 'mentor';

        return StreamBuilder<CourseModel?>(
          stream: _db.getCourse(widget.course.id),
          builder: (context, courseSnap) {
            final course = courseSnap.data ?? widget.course;
            final isUserEnrolled = course.enrolledStudentIds.contains(_uid);
            final isPending = course.enrollmentPendingIds.contains(_uid);
            final isCourseMentor = isMentor && course.mentorId == _uid;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Prevent "yellow line" overflow indicator if background logic conflicts
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          _getImagePath(course.title, course.category) == 'pcb_custom'
                              ? Container(color: AppColors.primary)
                              : Image.asset(
                                  _getImagePath(course.title, course.category),
                                  fit: BoxFit.cover,
                                ),
                          // Dark Overlay Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1000),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        course.category.toUpperCase(), 
                                        style: const TextStyle(
                                          color: Colors.white, 
                                          fontSize: 9, 
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      course.title, 
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 28, 
                                        fontWeight: FontWeight.w900, 
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 20,
                                      runSpacing: 10,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        _buildHeaderStat(Icons.timer_outlined, course.duration),
                                        _buildHeaderStat(Icons.people_alt_outlined, '${course.enrolledStudentIds.length} Enrolled'),
                                        _buildHeaderStat(Icons.layers_outlined, course.difficulty),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instructor
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        course.instructor.length >= 2 ? course.instructor.substring(0, 2).toUpperCase() : 'ME',
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Instructor', style: AppTextStyles.caption),
                                        Text(course.instructor, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _difficultyColor(course.difficulty).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      course.difficulty,
                                      style: TextStyle(color: _difficultyColor(course.difficulty), fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                          // Mentor Actions
                          if (isCourseMentor) ...[
                            const SizedBox(height: 24),
                            const Text('Mentor Actions', style: AppTextStyles.heading3),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ActionChip(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: AppColors.primary),
                                  label: const Text('+ Live Session'),
                                  onPressed: () => _addLiveSession(course),
                                ),
                                ActionChip(
                                  backgroundColor: AppColors.info.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: AppColors.info),
                                  label: const Text('+ Material'),
                                  onPressed: () => _addMaterial(course),
                                ),
                                ActionChip(
                                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: AppColors.warning),
                                  label: const Text('+ Assignment'),
                                  onPressed: () => _addAssignment(course),
                                ),
                                ActionChip(
                                  backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: AppColors.secondary),
                                  label: const Text('View Enrolled'),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => EnrolledStudentsScreen(course: course),
                                    ));
                                  },
                                ),
                                if (course.status != 'finished')
                                  ActionChip(
                                    backgroundColor: AppColors.success.withValues(alpha: 0.2),
                                    labelStyle: const TextStyle(color: AppColors.success),
                                    label: const Text('Finish Course'),
                                    onPressed: () => _finishCourse(course),
                                  ),
                                ActionChip(
                                  backgroundColor: AppColors.error.withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(color: AppColors.error),
                                  label: const Text('Delete Course'),
                                  onPressed: () => _deleteCourse(course),
                                ),
                              ],
                            ),
                          ],

                          // Course Content
                          const SizedBox(height: 24),
                          const Text('Live Sessions', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          if (!isUserEnrolled && !isMentor)
                            _buildLockedContent('Enroll to view live sessions')
                          else if (course.liveSessions.isEmpty)
                            const Text('No live sessions scheduled.', style: AppTextStyles.body)
                          else
                            ...course.liveSessions.map((session) => ListTile(
                              leading: const Icon(Icons.videocam_rounded, color: AppColors.primary),
                              title: Text(session.title, style: AppTextStyles.label),
                              subtitle: Text(session.time, style: AppTextStyles.caption),
                              trailing: TextButton(
                                onPressed: () {
                                  if (session.link.isNotEmpty) {
                                    launchUrl(Uri.parse(session.link), mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting link not available')));
                                  }
                                }, 
                                child: const Text('Join'),
                              ),
                            )),

                          const SizedBox(height: 24),
                          const Text('Materials', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          if (!isUserEnrolled && !isMentor)
                            _buildLockedContent('Enroll to access materials')
                          else 
                            StreamBuilder<List<MaterialModel>>(
                              stream: _db.getCourseMaterials(course.id),
                              builder: (context, matSnap) {
                                if (matSnap.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
                                final materials = matSnap.data ?? [];
                                if (materials.isEmpty) return const Text('No materials uploaded.', style: AppTextStyles.body);
                                
                                return Column(
                                  children: materials.map((mat) => ListTile(
                                    onTap: () => launchUrl(Uri.parse(mat.url), mode: LaunchMode.externalApplication),
                                    leading: Icon(_getFileIcon(mat.url), color: AppColors.info),
                                    title: Text(mat.title, style: AppTextStyles.label),
                                    subtitle: Text(mat.url, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textLight),
                                  )).toList(),
                                );
                              }
                            ),

                          const SizedBox(height: 24),
                          const Text('Assignments', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          if (!isUserEnrolled && !isMentor)
                            _buildLockedContent('Enroll to view assignments')
                          else
                            StreamBuilder<List<AssignmentModel>>(
                              stream: _db.getCourseAssignments(course.id),
                              builder: (context, assignSnap) {
                                if (assignSnap.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
                                final assignments = assignSnap.data ?? [];
                                if (assignments.isEmpty) return const Text('No assignments yet.', style: AppTextStyles.body);
                                
                                return Column(
                                  children: assignments.map((assign) => Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: AppDecorations.cardDecoration.copyWith(color: Colors.white),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: assign, isMentor: isCourseMentor)));
                                      },
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.assignment_rounded, color: AppColors.warning, size: 20),
                                      ),
                                      title: Text(assign.title, style: AppTextStyles.label),
                                      subtitle: Text('Due: ${assign.dueDate}', style: AppTextStyles.caption),
                                      trailing: assign.attachmentUrl != null 
                                        ? const Icon(Icons.attachment, size: 18, color: AppColors.primary)
                                        : const Icon(Icons.chevron_right, size: 18, color: AppColors.textLight),
                                    ),
                                  )).toList(),
                                );
                              }
                            ),

                          const SizedBox(height: 32),

                          if (!isMentor) // Mentors shouldn't have enroll buttons
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: (isUserEnrolled || isPending) ? null : () => _enrollCourse(course),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUserEnrolled 
                                      ? AppColors.success 
                                      : (isPending ? AppColors.textLight : AppColors.primary),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  isUserEnrolled ? 'Enrolled' : (isPending ? 'Request Pending' : 'Enroll Now'),
                                  style: AppTextStyles.buttonText,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildLockedContent(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.lock_person_rounded, color: AppColors.textLight, size: 32),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getImagePath(String title, String category) {
    final t = '$title $category'.toLowerCase();
    if (t.contains('java') && !t.contains('javascript')) return 'assets/java_logo.png';
    if (t.contains('python')) return 'assets/python_logo.png';
    if (t.contains('embedded') || t.contains('iot')) return 'assets/iot_embedded_logo.png';
    if (t.contains('ai') && t.contains('web')) return 'assets/ai_web_dev_logo.png';
    if (t.contains('ai') && t.contains('ml')) return 'assets/ai_ml_logo.png';
    if (t.contains('ai')) return 'assets/ai_logo.png';
    if (t.contains('web') || t.contains('javascript') || t.contains('fullstack') || t.contains('full-stack') ||
        t.contains('frontend') || t.contains('front-end') || t.contains('backend') || t.contains('back-end') ||
        t.contains('react') || t.contains('node') || t.contains('mern') || t.contains('mean') || t.contains('html') || t.contains('css')) {
      return 'assets/web_dev_logo.png';
    }
    if (t.contains('pcb') || t.contains('hardware') || t.contains('circuit') || t.contains('schematic') || t.contains('vlsi')) {
      return 'pcb_custom'; 
    }
    if (RegExp(r'\bc\b').hasMatch(t)) return 'assets/c_logo.png';
    return 'assets/default_logo.png';
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Beginner': return AppColors.success;
      case 'Intermediate': return AppColors.warning;
      case 'Advanced': return AppColors.error;
      default: return AppColors.info;
    }
  }

  IconData _getFileIcon(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.pdf')) return Icons.picture_as_pdf_rounded;
    if (lower.contains('.jpg') || lower.contains('.png') || lower.contains('.jpeg')) return Icons.image_rounded;
    if (lower.contains('.zip') || lower.contains('.rar')) return Icons.archive_rounded;
    if (lower.contains('.doc') || lower.contains('.docx')) return Icons.description_rounded;
    if (lower.contains('.mp4') || lower.contains('.mov')) return Icons.movie_rounded;
    return Icons.insert_drive_file_rounded;
  }
}

