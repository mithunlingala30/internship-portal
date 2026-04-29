  import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final bool isMentor;
  const AssignmentDetailScreen({super.key, required this.assignment, required this.isMentor});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final FirestoreService _db = FirestoreService();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  void _submitWork() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a submission link')));
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final userModel = await _db.getUserFuture(user.uid);
      
      final submission = SubmissionModel(
        id: '',
        assignmentId: widget.assignment.id,
        studentId: user.uid,
        studentName: userModel?.name ?? 'Student',
        fileUrl: _urlController.text.trim(),
        fileName: 'Submission Link',
        submittedAt: DateTime.now(),
      );

      await _db.submitWork(submission);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Working submitted successfully!')));
        Navigator.pop(context);
      }
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
        title: const Text('Assignment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.assignment.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${widget.assignment.maxScore} points • Due ${widget.assignment.dueDate}', 
                           style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 48),
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text(widget.assignment.description.isEmpty ? 'No instructions provided.' : widget.assignment.description,
                 style: const TextStyle(height: 1.5, fontSize: 15)),
            
            if (widget.assignment.attachmentUrl != null) ...[
              const SizedBox(height: 24),
              const Text('Reference Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => launchUrl(Uri.parse(widget.assignment.attachmentUrl!), mode: LaunchMode.externalApplication),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('View Reference Link', style: TextStyle(fontWeight: FontWeight.w500))),
                      const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),

            if (widget.isMentor) ...[
              const Text('Student Submissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              StreamBuilder<List<SubmissionModel>>(
                stream: _db.getAssignmentSubmissions(widget.assignment.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final subs = snap.data ?? [];
                  if (subs.isEmpty) return const Text('No students have submitted yet.', style: TextStyle(color: Colors.grey));
                  
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sub = subs[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(sub.studentName[0])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sub.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Link: ${sub.fileUrl}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                              onPressed: () => launchUrl(Uri.parse(sub.fileUrl), mode: LaunchMode.externalApplication),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              ),
            ] else ...[
              // Student View - Submit Link
              StreamBuilder<SubmissionModel?>(
                stream: _db.getUserSubmission(widget.assignment.id, FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snap) {
                  final existingSub = snap.data;
                  
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (existingSub != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 12),
                                const Expanded(child: Text('Submitted', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => launchUrl(Uri.parse(existingSub.fileUrl), mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('View Submission'),
                          ),
                        ] else ...[
                          TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              hintText: 'Submission Link (Google Drive, Doc, etc.)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitWork,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Turn in', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
              ),
            ],
          ],
        ),
      ),
    );
  }
}
