import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'pcb_icon.dart';

// ─── Horizontal Course Card (used in Home screen) ─────────────────────────────
class CourseCardHorizontal extends StatelessWidget {
  final CourseModel course;
  const CourseCardHorizontal({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Portion
          Stack(
            children: [
              _getImagePath(course.title, course.category) == 'pcb_custom'
                ? const PCBIcon(size: 100)
                : Image.asset(
                    _getImagePath(course.title, course.category),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.courseCode,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (course.status == 'finished')
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Finished', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                )
              else if (course.status == 'ongoing')
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Ongoing', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course.instructor,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      course.createdAt != null 
                        ? '${course.createdAt!.day}/${course.createdAt!.month}/${course.createdAt!.year}'
                        : 'Recently',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
    
    // Expanded web keywords
    if (t.contains('web') || 
        t.contains('javascript') || 
        t.contains('fullstack') || 
        t.contains('full-stack') ||
        t.contains('frontend') || 
        t.contains('front-end') ||
        t.contains('backend') ||
        t.contains('back-end') ||
        t.contains('react') ||
        t.contains('node') ||
        t.contains('mern') ||
        t.contains('mean') ||
        t.contains('html') ||
        t.contains('css')) {
      return 'assets/web_dev_logo.png';
    }
    
    if (t.contains('pcb') || 
        t.contains('hardware') || 
        t.contains('circuit') || 
        t.contains('schematic') || 
        t.contains('vlsi')) {
      return 'pcb_custom'; 
    }
    
    if (RegExp(r'\bc\b').hasMatch(t)) return 'assets/c_logo.png';
    
    return 'assets/default_logo.png';
  }
}

// ─── Vertical Course Card (used in Courses screen) ────────────────────────────
class CourseCardVertical extends StatelessWidget {
  final CourseModel course;
  const CourseCardVertical({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Visual element
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              image: _getImagePath(course.title, course.category) == 'pcb_custom'
                  ? null
                  : DecorationImage(
                      image: AssetImage(_getImagePath(course.title, course.category)),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Stack(
              children: [
                if (_getImagePath(course.title, course.category) == 'pcb_custom')
                  const Positioned.fill(child: PCBIcon()),
                if (course.status == 'finished')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('FINISHED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  )
                else if (course.status == 'ongoing')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ONGOING', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Chip(label: course.courseCode, color: AppColors.secondary),
                      _Chip(label: course.category, color: AppColors.primary),
                      Text(course.difficulty, style: TextStyle(color: _diffColor(course.difficulty), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(course.title, style: AppTextStyles.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    course.duration,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 22),
          ),
        ],
      ),
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
    
    if (t.contains('web') || 
        t.contains('javascript') || 
        t.contains('fullstack') || 
        t.contains('full-stack') ||
        t.contains('frontend') || 
        t.contains('front-end') ||
        t.contains('backend') ||
        t.contains('back-end') ||
        t.contains('react') ||
        t.contains('node') ||
        t.contains('mern') ||
        t.contains('mean') ||
        t.contains('html') ||
        t.contains('css')) {
      return 'assets/web_dev_logo.png';
    }
    
    if (t.contains('pcb') || 
        t.contains('hardware') || 
        t.contains('circuit') || 
        t.contains('schematic') || 
        t.contains('vlsi')) {
      return 'pcb_custom'; 
    }
    
    if (RegExp(r'\bc\b').hasMatch(t)) return 'assets/c_logo.png';
    
    return 'assets/default_logo.png';
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Beginner': return AppColors.success;
      case 'Intermediate': return AppColors.warning;
      case 'Advanced': return AppColors.error;
      default: return AppColors.info;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final LinearGradient gradient;
  const StatsCard({super.key, required this.label, required this.value, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Announcement Card ────────────────────────────────────────────────────────
class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(announcement.type);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: announcement.isRead ? null : Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(_typeIcon(announcement.type), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!announcement.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(announcement.message, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(announcement.author, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.primary)),
                      const Text(' · ', style: TextStyle(color: AppColors.textLight)),
                      Text(announcement.timeAgo, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'urgent': return AppColors.error;
      default: return AppColors.info;
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'success': return Icons.check_circle_outline_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      case 'urgent': return Icons.error_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
