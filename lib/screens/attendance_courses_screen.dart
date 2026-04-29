import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'mark_attendance_screen.dart';
import 'attendance_report_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceCoursesScreen extends StatelessWidget {
  const AttendanceCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classes & Training', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.0, 0.2],
          ),
        ),
        child: StreamBuilder<List<CourseModel>>(
        stream: uid != null ? FirestoreService().getMentorCourses(uid) : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available.'));
          }

          final courses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 4),
                      title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text('${course.enrolledStudentIds.length} Students Enrolled'),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Show the 'Mark Attendance' button first or keep logic consistent
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => AttendanceReportScreen(course: course),
                                ));
                              },
                              icon: const Icon(Icons.bar_chart, size: 18, color: AppColors.primary),
                              label: const Text('Attendance Report', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => MarkAttendanceScreen(course: course),
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Mark Attendance'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            );
          },
        ),
      ),
    );
  }
}
