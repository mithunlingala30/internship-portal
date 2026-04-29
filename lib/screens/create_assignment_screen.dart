import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final CourseModel course;
  const CreateAssignmentScreen({super.key, required this.course});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  final _scoreController = TextEditingController(text: '100');
  final FirestoreService _db = FirestoreService();

  bool _isLoading = false;
  DateTime? _dueDate;

  void _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final attachmentUrl = _urlController.text.trim().isEmpty ? null : _urlController.text.trim();

      final assignment = AssignmentModel(
        id: '',
        courseId: widget.course.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        courseName: widget.course.title,
        dueDate: _dueDate != null ? DateFormat('MMM d, yyyy').format(_dueDate!) : 'No due date',
        status: 'pending',
        maxScore: int.tryParse(_scoreController.text) ?? 100,
        priority: 'medium',
        attachmentUrl: attachmentUrl,
      );

      await _db.createAssignment(assignment);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Assignment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Assign', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assignment details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black26),
              ),
            ),
            const Divider(),
            TextField(
              controller: _descController,
              maxLines: null,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Instructions (optional)',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black26),
                icon: Icon(Icons.description_outlined, color: Colors.black38),
              ),
            ),
            const Divider(),
            TextField(
              controller: _urlController,
              maxLines: null,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Reference Link (optional)',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black26),
                icon: Icon(Icons.link, color: Colors.black38),
              ),
            ),
            const Divider(height: 48),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stars_outlined, color: Colors.black45),
              title: const Text('Points', style: TextStyle(fontSize: 15)),
              trailing: SizedBox(
                width: 60,
                child: TextField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_outlined, color: Colors.black45),
              onTap: _pickDate,
              title: const Text('Due Date', style: TextStyle(fontSize: 15)),
              trailing: Text(
                _dueDate != null ? DateFormat('MMM d, yyyy').format(_dueDate!) : 'No due date',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All students in ${widget.course.title} will be notified of this assignment immediately.',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
