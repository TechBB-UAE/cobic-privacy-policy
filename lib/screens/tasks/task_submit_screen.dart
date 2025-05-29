import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cobic/services/task_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:image/image.dart' as img;

class TaskSubmitScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const TaskSubmitScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskSubmitScreen> createState() => _TaskSubmitScreenState();
}

class _TaskSubmitScreenState extends State<TaskSubmitScreen> {
  XFile? _pickedImage;
  bool _isSubmitting = false;
  Map<String, dynamic>? _submission;

  @override
  void initState() {
    super.initState();
    _loadSubmission();
  }

  Future<void> _loadSubmission() async {
    try {
      final submission = await TaskService.getTaskSubmission(widget.task['id']);
      if (mounted) {
        setState(() {
          _submission = submission;
        });
      }
    } catch (e) {
      // Ignore error if no submission exists
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<void> _submitTask() async {
    if (_pickedImage == null) return;
    setState(() => _isSubmitting = true);
    try {
      final bytes = await _pickedImage!.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Không thể xử lý ảnh');
      }
      
      final compressed = img.encodeJpg(image, quality: 60);
      final base64Str = base64Encode(compressed);
      final proofImage = 'data:image/jpeg;base64,$base64Str';
      final taskId = widget.task['id'].toString();
      
      await TaskService.submitTask(taskId: taskId, proofImage: proofImage);
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
    }
  }

  Widget _buildSubmissionStatus() {
    if (_submission == null) return const SizedBox.shrink();

    final status = _submission!['status'] as String;
    final rejectionReason = _submission!['rejectionReason'] as String?;
    final submittedAt = DateTime.parse(_submission!['submittedAt'] as String);
    final reviewedAt = _submission!['reviewedAt'] != null 
        ? DateTime.parse(_submission!['reviewedAt'] as String)
        : null;

    Color statusColor;
    String statusText;
    String? detailText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Đang chờ duyệt';
        detailText = 'Gửi lúc: ${submittedAt.toString().substring(0, 16)}';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Đã được duyệt';
        detailText = 'Duyệt lúc: ${reviewedAt?.toString().substring(0, 16)}';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Bị từ chối';
        detailText = rejectionReason ?? 'Không có lý do';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (detailText != null) ...[
            const SizedBox(height: 8),
            Text(
              detailText,
              style: TextStyle(
                color: statusColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(
        title: Text(task['title'] ?? 'Thực hiện nhiệm vụ'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: AppTheme.lightTheme.cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined, color: AppTheme.lightTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Nội dung nhiệm vụ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task['description'] ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_submission != null) ...[
                _buildSubmissionStatus(),
                const SizedBox(height: 24),
              ],
              if (_submission == null) ...[
                Card(
                  elevation: 0,
                  color: AppTheme.lightTheme.cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image_outlined, color: AppTheme.lightTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Ảnh minh chứng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: _pickedImage == null
                            ? InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Chọn ảnh từ thư viện',
                                        style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Material(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                      child: InkWell(
                                        onTap: _pickImage,
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(Icons.edit, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _pickedImage == null || _isSubmitting ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Gửi nhiệm vụ'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 