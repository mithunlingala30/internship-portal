import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class MentorAssignmentsScreen extends StatefulWidget {
  const MentorAssignmentsScreen({super.key});

  @override
  State<MentorAssignmentsScreen> createState() => _MentorAssignmentsScreenState();
}

class _MentorAssignmentsScreenState extends State<MentorAssignmentsScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssignmentModel>>(
      stream: _db.assignments,
      builder: (context, snapshot) {
        final assignments = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Manage Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Implement Create Assignment logic
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: assignments.isEmpty
              ? const Center(child: Text('No tasks created yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) => _MentorAssignmentCard(assignment: assignments[index]),
                ),
        );
      },
    );
  }
}

class _MentorAssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  const _MentorAssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    assignment.courseName,
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: AppColors.textLight),
              ],
            ),
            const SizedBox(height: 12),
            Text(assignment.title, style: AppTextStyles.heading3),
            const SizedBox(height: 6),
            Text(
              assignment.description,
              style: AppTextStyles.bodySecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.people_outline,
                  label: 'Submissions',
                  value: '12/24', // Mock data for now
                ),
                _StatItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due Date',
                  value: assignment.dueDate,
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
      ],
    );
  }
}
