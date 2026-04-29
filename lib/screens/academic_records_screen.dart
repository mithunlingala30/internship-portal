import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AcademicRecordsScreen extends StatelessWidget {
  final UserModel user;
  const AcademicRecordsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    final isMentor = user.role == 'mentor';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Academic Records', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: isMentor 
          ? _buildMentorRecords(db) 
          : _buildStudentRecords(db),
    );
  }

  Widget _buildMentorRecords(FirestoreService db) {
    return StreamBuilder<List<CourseModel>>(
      stream: db.getMentorCourses(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return const Center(child: Text('No courses created yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final dateStr = course.createdAt != null 
                ? DateFormat('MMM dd, yyyy').format(course.createdAt!)
                : 'Date not available';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                ),
                title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Created on: $dateStr'),
                    Text('Students: ${course.enrolledStudentIds.length} enrolled'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentRecords(FirestoreService db) {
    return StreamBuilder<List<EnrollmentModel>>(
      stream: db.getUserEnrollments(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final enrollments = snapshot.data ?? [];
        if (enrollments.isEmpty) {
          return const Center(child: Text('No courses registered yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: enrollments.length,
          itemBuilder: (context, index) {
            final record = enrollments[index];
            final dateStr = DateFormat('MMM dd, yyyy').format(record.enrolledAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppColors.success),
                ),
                title: Text(record.courseTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Registered on: $dateStr'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
