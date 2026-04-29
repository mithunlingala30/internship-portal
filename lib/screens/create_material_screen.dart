import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class CreateMaterialScreen extends StatefulWidget {
  final CourseModel course;
  const CreateMaterialScreen({super.key, required this.course});

  @override
  State<CreateMaterialScreen> createState() => _CreateMaterialScreenState();
}

class _CreateMaterialScreenState extends State<CreateMaterialScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final FirestoreService _db = FirestoreService();
  
  bool _isLoading = false;

  void _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a valid URL')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final material = MaterialModel(
        id: '',
        courseId: widget.course.id,
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      await _db.createMaterial(material);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Material', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
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
                : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Material details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
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
                  controller: _urlController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Resource Link (Google Drive, YouTube, etc.)',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black26),
                    icon: Icon(Icons.link, color: Colors.black38),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 40),
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
                          'This link will be accessible to all enrolled students in ${widget.course.title}.',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

