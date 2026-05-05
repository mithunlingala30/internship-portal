import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'create_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  final bool onlyEnrolled;
  const CoursesScreen({super.key, this.onlyEnrolled = false});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedStatus = 'ongoing';
  final FirestoreService _db = FirestoreService();

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _selectedDifficulty != null ||
      _selectedStatus != null;

  void _showFilterSheet(BuildContext context, List<CourseModel> allCourses) {
    // Collect unique categories from courses
    final categories = allCourses.map((c) => c.category).toSet().toList()
      ..sort();

    String? tempCategory = _selectedCategory;
    String? tempDifficulty = _selectedDifficulty;
    String? tempStatus = _selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Header row
                Row(
                  children: [
                    const Text('Filter Courses', style: AppTextStyles.heading3),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          tempCategory = null;
                          tempDifficulty = null;
                          tempStatus = null;
                        });
                      },
                      child: const Text('Clear All',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Category ────────────────────────────────────────────
                if (categories.isNotEmpty) ...[
                  const Text('Category', style: AppTextStyles.label),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final selected = tempCategory == cat;
                      return GestureDetector(
                        onTap: () => setSheetState(() {
                          tempCategory = selected ? null : cat;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Difficulty ──────────────────────────────────────────
                const Text('Difficulty', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children:
                      ['Beginner', 'Intermediate', 'Advanced'].map((diff) {
                    final selected = tempDifficulty == diff;
                    final color = diff == 'Beginner'
                        ? AppColors.success
                        : diff == 'Intermediate'
                            ? AppColors.warning
                            : AppColors.error;
                    return GestureDetector(
                      onTap: () => setSheetState(() {
                        tempDifficulty = selected ? null : diff;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                selected ? color : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          diff,
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Status ──────────────────────────────────────────────
                const Text('Status', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    {
                      'label': 'Ongoing',
                      'value': 'ongoing',
                      'color': AppColors.info
                    },
                    {
                      'label': 'Finished',
                      'value': 'finished',
                      'color': AppColors.success
                    },
                  ].map((item) {
                    final val = item['value'] as String;
                    final label = item['label'] as String;
                    final color = item['color'] as Color;
                    final selected = tempStatus == val;
                    return GestureDetector(
                      onTap: () => setSheetState(() {
                        tempStatus = selected ? null : val;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                selected ? color : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // ── Apply button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = tempCategory;
                        _selectedDifficulty = tempDifficulty;
                        _selectedStatus = tempStatus;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters',
                        style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<UserModel?>(
        stream: uid != null ? _db.getUserModel(uid) : const Stream.empty(),
        builder: (context, userSnap) {
          final isMentor = userSnap.data?.role == 'mentor';

          return Scaffold(
            backgroundColor: AppColors.background,
            floatingActionButton: isMentor
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CreateCourseScreen()));
                    },
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    icon: const Icon(Icons.edit_note_rounded, size: 22),
                    label: const Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  )
                : null,
            body: StreamBuilder<List<CourseModel>>(
                stream: _db.courses,
                builder: (context, courseSnap) {
                  if (!courseSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allCourses = courseSnap.data!;

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        backgroundColor: AppColors.primary,
                        floating: true,
                        snap: true,
                        elevation: 0,
                        expandedHeight: _hasActiveFilters ? 230 : 200,
                        centerTitle: false,
                        title: innerBoxIsScrolled
                            ? Text(
                                widget.onlyEnrolled ? 'My Enrolled' : 'Courses',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                            : null,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 20,
                              left: MediaQuery.of(context).size.width > 800 ? 40 : 20,
                              right: MediaQuery.of(context).size.width > 800 ? 40 : 20,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.background
                                ],
                                stops: [0.0, 0.9],
                              ),
                            ),
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          widget.onlyEnrolled
                                              ? 'My Enrolled'
                                              : 'Courses',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5)),
                                      GestureDetector(
                                        onTap: () => _showFilterSheet(
                                            context, allCourses),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _hasActiveFilters
                                                ? Colors.white
                                                : Colors.white
                                                    .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.filter_list_rounded,
                                              color: _hasActiveFilters
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              size: 22),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                      'Manage and track your learning journeys',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 14)),

                                  // Active filter chips
                                  if (_hasActiveFilters) ...[
                                    const SizedBox(height: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          if (_selectedCategory != null)
                                            _ActiveFilterChip(
                                              label: _selectedCategory!,
                                              onRemove: () => setState(() =>
                                                  _selectedCategory = null),
                                            ),
                                          if (_selectedDifficulty != null)
                                            _ActiveFilterChip(
                                              label: _selectedDifficulty!,
                                              onRemove: () => setState(() =>
                                                  _selectedDifficulty = null),
                                            ),
                                          if (_selectedStatus != null)
                                            _ActiveFilterChip(
                                              label:
                                                  _selectedStatus == 'ongoing'
                                                      ? 'Ongoing'
                                                      : 'Finished',
                                              onRemove: () => setState(
                                                  () => _selectedStatus = null),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 14),
                                  // Search bar
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      onChanged: (v) =>
                                          setState(() => _searchQuery = v),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        hintText: 'Search courses...',
                                        hintStyle: TextStyle(
                                            color: AppColors.textLight,
                                            fontWeight: FontWeight.w400),
                                        prefixIcon: Icon(Icons.search_rounded,
                                            color: AppColors.primary, size: 22),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    body: _buildCourseList(
                      widget.onlyEnrolled
                          ? allCourses
                              .where((c) => c.enrolledStudentIds.contains(uid))
                              .toList()
                          : allCourses,
                    ),
                  );
                }),
          );
        });
  }

  Widget _buildCourseList(List<CourseModel> courses) {
    var filtered = courses.where((c) {
      // Search
      final q = _searchQuery.toLowerCase();
      if (q.isNotEmpty &&
          !c.title.toLowerCase().contains(q) &&
          !c.category.toLowerCase().contains(q) &&
          !c.courseCode.toLowerCase().contains(q)) {
        return false;
      }
      // Category filter
      if (_selectedCategory != null && c.category != _selectedCategory) {
        return false;
      }
      // Difficulty filter
      if (_selectedDifficulty != null && c.difficulty != _selectedDifficulty) {
        return false;
      }
      // Status filter
      if (_selectedStatus != null && c.status != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 52, color: AppColors.textLight),
            const SizedBox(height: 12),
            const Text('No courses found', style: AppTextStyles.body),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _selectedDifficulty = null;
                  _selectedStatus = null;
                }),
                child: const Text('Clear Filters',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: filtered[index])),
              ),
              child: CourseCardVertical(course: filtered[index]),
            );
          },
        ),
      ),
    );
  }
}

// Active filter chip displayed in the header
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}
