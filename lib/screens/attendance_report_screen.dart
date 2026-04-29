import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AttendanceReportScreen extends StatelessWidget {
  final CourseModel course;
  const AttendanceReportScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Attendance Report: ${course.title}', 
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: FirestoreService().getCourseAttendance(course.id),
        builder: (context, attendanceSnap) {
          final attendanceList = attendanceSnap.data ?? [];
          final totalStudents = course.enrolledStudentIds.length;
          
          int totalSessions = 0;
          double avgAttendance = 0;
          
          if (attendanceList.isNotEmpty) {
            totalSessions = attendanceList.map((e) => e.totalSessions).reduce((a, b) => a > b ? a : b);
            avgAttendance = attendanceList.map((e) => e.percentage).reduce((a, b) => a + b) / attendanceList.length;
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.background],
                stops: [0.0, 0.3],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Course Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Students', totalStudents.toString(), Icons.people_outline),
                              _buildStatItem('Average', '${avgAttendance.toInt()}%', Icons.analytics_outlined),
                              _buildStatItem('Sessions', totalSessions.toString(), Icons.event_available),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: course.enrolledStudentIds.isEmpty
                      ? const Center(child: Text('No students enrolled.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: course.enrolledStudentIds.length,
                          itemBuilder: (context, index) {
                            final studentId = course.enrolledStudentIds[index];
                            final record = attendanceList.firstWhere(
                              (e) => e.studentId == studentId,
                              orElse: () => AttendanceModel(
                                studentId: studentId,
                                courseId: course.id,
                                courseName: course.title,
                                totalSessions: 0,
                                attendedSessions: 0,
                              ),
                            );

                            return FutureBuilder<UserModel?>(
                              future: FirestoreService().getUserFuture(studentId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Card(margin: EdgeInsets.only(bottom: 12), child: ListTile(title: Text('Loading...')));
                                }
                                final student = snapshot.data;
                                if (student == null) return const SizedBox.shrink();

                                final double percentage = record.percentage;
                                final Color progressColor = percentage > 75 ? AppColors.success : (percentage > 50 ? AppColors.warning : AppColors.error);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                          child: Text(student.avatarInitials, 
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(student.name, 
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text('${record.attendedSessions}/${record.totalSessions} sessions attended', 
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                              const SizedBox(height: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: LinearProgressIndicator(
                                                  value: record.totalSessions == 0 ? 0 : percentage / 100,
                                                  backgroundColor: Colors.grey[200],
                                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                                  minHeight: 6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: progressColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${percentage.toInt()}%',
                                            style: TextStyle(
                                              color: progressColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
