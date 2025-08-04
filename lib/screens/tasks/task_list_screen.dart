import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'task_submit_screen.dart';
import 'package:cobic/services/task_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
import 'package:flutter/cupertino.dart';
import '../../l10n/app_localizations.dart';
import 'package:cobic/widgets/language_switch_button.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = false;
  String? error;
  int _currentPage = 0;
  final int _pageSize = 10;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  List<Map<String, dynamic>> _filterTasks() {
    if (_selectedStatus == 'all') return tasks;
    return tasks.where((task) {
      final submission = task['submission'] as Map<String, dynamic>?;
      if (_selectedStatus == 'not_submitted') return submission == null;
      if (submission == null) return false;
      final status = submission['status'] as String?;
      return status == _selectedStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get pagedTasks {
    final filteredTasks = _filterTasks();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize) > filteredTasks.length ? filteredTasks.length : (start + _pageSize);
    return filteredTasks.sublist(start, end);
  }

  void _nextPage() {
    final filteredTasks = _filterTasks();
    if ((_currentPage + 1) * _pageSize < filteredTasks.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
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
        _currentPage = 0;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.tasks,
        actions: [
          const LanguageSwitchButton(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              tooltip: themeProvider.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
              onPressed: () {
                themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const ScanQrScreen(targetRoute: '/home')),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.home, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedStatus,
                        backgroundColor: Theme.of(context).cardColor,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        children: <String, Widget>{
                          'all': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              l10n.all,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedStatus == 'all'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          'not_submitted': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              l10n.notSubmitted,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedStatus == 'not_submitted'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          'pending': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              l10n.pendingTask,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedStatus == 'pending'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          'approved': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              l10n.approvedTask,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedStatus == 'approved'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          'rejected': Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              l10n.rejectedTask,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedStatus == 'rejected'
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                              _currentPage = 0;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: pagedTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = pagedTasks[index];
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
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: Text('Thực hiện', style: TextStyle(fontWeight: FontWeight.bold)),
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

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
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
                                    ? Theme.of(context).colorScheme.primary
                                    : status == 'pending'
                                        ? Colors.orange
                                        : status == 'approved'
                                            ? Colors.green
                                            : Colors.red,
                              ),
                              title: Text(
                                task['title'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                task['description'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: buildStatusButton(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _currentPage > 0 ? _prevPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(_currentPage > 0 ? 1 : 0.4),
                            foregroundColor: Colors.white,
                            shadowColor: Colors.white24,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: Text(
                            l10n.previousPage,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: ((_currentPage + 1) * _pageSize < _filterTasks().length) ? _nextPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(((_currentPage + 1) * _pageSize < _filterTasks().length) ? 1 : 0.4),
                            foregroundColor: Colors.white,
                            shadowColor: Colors.white24,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: const Text('Trang sau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trang ${_currentPage + 1} / ${(_filterTasks().isEmpty ? 1 : (_filterTasks().length / _pageSize).ceil())}',
                      style: TextStyle(color: AppTheme.secondaryTextColor),
                    ),
                  ],
                ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'all':
        return 'Tất cả';
      case 'not_submitted':
        return 'Chưa nộp';
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã được duyệt';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return status;
    }
  }
} 