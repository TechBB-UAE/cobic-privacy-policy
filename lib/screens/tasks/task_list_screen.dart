import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'task_submit_screen.dart';
import 'package:cobic/services/task_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/screens/scan_qr_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await TaskService.fetchTasks();
      setState(() {
        tasks = data;
      });
    } catch (e) {
      error = ErrorUtils.parseApiError(e);
      ErrorUtils.showErrorToast(context, error ?? 'Lỗi không xác định');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhiệm vụ'),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const ScanQrScreen(targetRoute: '/home')),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final submission = task['submission'] as Map<String, dynamic>?;
                    final bool hasSubmission = submission != null;
                    final String? status = submission?['status'] as String?;
                    final String? rejectionReason = submission?['rejectionReason'] as String?;
                    final DateTime? submittedAt = submission?['submittedAt'] != null 
                        ? DateTime.parse(submission!['submittedAt'] as String)
                        : null;
                    final DateTime? reviewedAt = submission?['reviewedAt'] != null
                        ? DateTime.parse(submission!['reviewedAt'] as String)
                        : null;

                    Widget buildStatusButton() {
                      if (!hasSubmission) {
                        return ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TaskSubmitScreen(task: task),
                              ),
                            );
                            if (result == true) {
                              await fetchTasks();
                              if (mounted) {
                                ErrorUtils.showSuccessToast(context, 'Cập nhật trạng thái nhiệm vụ thành công!');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text('Thực hiện'),
                        );
                      }

                      Color statusColor;
                      String statusText;

                      switch (status) {
                        case 'pending':
                          statusColor = Colors.orange;
                          statusText = 'Đang chờ duyệt';
                          break;
                        case 'approved':
                          statusColor = Colors.green;
                          statusText = 'Đã được duyệt';
                          break;
                        case 'rejected':
                          statusColor = Colors.red;
                          statusText = 'Bị từ chối';
                          break;
                        default:
                          statusColor = Colors.grey;
                          statusText = 'Không xác định';
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        constraints: const BoxConstraints(maxWidth: 100),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Card(
                      color: AppTheme.lightTheme.cardTheme.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(
                          !hasSubmission 
                              ? Icons.assignment 
                              : status == 'pending'
                                  ? Icons.access_time
                                  : status == 'approved'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                          color: !hasSubmission 
                              ? AppTheme.lightTheme.primaryColor
                              : status == 'pending'
                                  ? Colors.orange
                                  : status == 'approved'
                                      ? AppTheme.successColor
                                      : Colors.red,
                        ),
                        title: Text(
                          task['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          task['description'] ?? '',
                          style: TextStyle(color: AppTheme.secondaryTextColor),
                        ),
                        trailing: buildStatusButton(),
                      ),
                    );
                  },
                ),
    );
  }
} 