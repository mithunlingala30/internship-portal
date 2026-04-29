import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final CourseModel course;
  const MarkAttendanceScreen({super.key, required this.course});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Map<String, bool> _attendance = {};

  @override
  void initState() {
    super.initState();
    for (var id in widget.course.enrolledStudentIds) {
      _attendance[id] = true; // Default to present
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mark Attendance: ${widget.course.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
            stops: [0.0, 0.15],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: widget.course.enrolledStudentIds.isEmpty
                  ? const Center(child: Text('No students enrolled in this course.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: widget.course.enrolledStudentIds.length,
                      itemBuilder: (context, index) {
                        final studentId = widget.course.enrolledStudentIds[index];
                        return FutureBuilder<UserModel?>(
                          future: FirestoreService().getUserFuture(studentId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(title: Text('Loading student...')),
                              );
                            }
                            final student = snapshot.data;
                            if (student == null) return const SizedBox.shrink();
                            
                            final isPresent = _attendance[studentId] ?? false;
        
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: AppDecorations.cardDecoration,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    foregroundColor: AppColors.primary,
                                    child: Text(student.avatarInitials, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                        Text(student.email, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('Absent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        selected: !isPresent,
                                        selectedColor: AppColors.error.withValues(alpha: 0.2),
                                        onSelected: (val) => setState(() => _attendance[studentId] = false),
                                        labelStyle: TextStyle(color: !isPresent ? AppColors.error : AppColors.textLight),
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide(color: !isPresent ? AppColors.error : AppColors.divider),
                                        showCheckmark: false,
                                      ),
                                      ChoiceChip(
                                        label: const Text('Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        selected: isPresent,
                                        selectedColor: AppColors.success.withValues(alpha: 0.2),
                                        onSelected: (val) => setState(() => _attendance[studentId] = true),
                                        labelStyle: TextStyle(color: isPresent ? AppColors.success : AppColors.textLight),
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide(color: isPresent ? AppColors.success : AppColors.divider),
                                        showCheckmark: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            if (widget.course.enrolledStudentIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      try {
                        await FirestoreService().updateAttendanceBatch(
                          widget.course.id,
                          widget.course.title,
                          _attendance,
                        );
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Attendance saved successfully!')),
                        );
                        navigator.pop();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error saving attendance: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Submit Attendance', style: AppTextStyles.buttonText),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
