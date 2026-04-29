import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _db = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssignmentModel>>(
      stream: _db.assignments,
      builder: (context, snapshot) {
        final assignments = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (_, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: AppColors.primary,
                floating: true,
                pinned: true,
                snap: false,
                elevation: 0,
                expandedHeight: 160,
                centerTitle: false,
                title: innerBoxIsScrolled
                    ? const Text('Assignments',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold))
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.background],
                        stops: [0.0, 0.9],
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text('Assignments',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text(
                            '${assignments.length} total assignments',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorPadding: const EdgeInsets.all(3),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 12),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Pending'),
                        Tab(text: 'Submitted'),
                        Tab(text: 'Graded'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildList(assignments),
                _buildList(assignments.where((a) => a.status == 'pending' || a.status == 'overdue').toList()),
                _buildList(assignments.where((a) => a.status == 'submitted').toList()),
                _buildList(assignments.where((a) => a.status == 'graded').toList()),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildList(List<AssignmentModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No assignments here', style: AppTextStyles.body),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _AssignmentCard(assignment: items[index]),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: AppDecorations.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _priorityColor(assignment.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.assignment_outlined, color: _priorityColor(assignment.priority), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(assignment.title, style: AppTextStyles.cardTitle),
                        const SizedBox(height: 2),
                        Text(assignment.courseName, style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  _StatusChip(status: assignment.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text('Due ${assignment.dueDate}', style: AppTextStyles.bodySmall),
                  const Spacer(),
                  if (assignment.status == 'graded' && assignment.score != null)
                    Text(
                      'Score: ${assignment.score}/${assignment.maxScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.description,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (assignment.status == 'pending')
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'pending':
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        label = 'Pending';
        break;
      case 'submitted':
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        label = 'Submitted';
        break;
      case 'graded':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        label = 'Graded';
        break;
      case 'overdue':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        label = 'Overdue';
        break;
      default:
        bg = AppColors.textLight.withValues(alpha: 0.2);
        fg = AppColors.textLight;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}
