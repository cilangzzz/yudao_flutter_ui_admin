import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/job_api.dart';
import '../../../models/infra/job.dart';
import '../../../i18n/i18n.dart';
import 'widgets/job_search_form.dart';
import 'widgets/job_action_buttons.dart';
import 'widgets/job_data_table.dart';
import 'dialogs/job_form_dialog.dart';
import 'dialogs/job_detail_dialog.dart';
import 'job_log_page.dart';

/// 定时任务管理页面
class JobPage extends ConsumerStatefulWidget {
  const JobPage({super.key});

  @override
  ConsumerState<JobPage> createState() => _JobPageState();
}

class _JobPageState extends ConsumerState<JobPage> {
  final _nameController = TextEditingController();
  final _handlerNameController = TextEditingController();
  int? _selectedStatus;

  List<Job> _jobList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadJobList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handlerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadJobList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobApi = ref.read(jobApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_handlerNameController.text.isNotEmpty) 'handlerName': _handlerNameController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };

      final response = await jobApi.getJobPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _jobList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg ?? S.current.loadFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search() {
    setState(() => _currentPage = 1);
    _loadJobList();
  }

  void _reset() {
    _nameController.clear();
    _handlerNameController.clear();
    setState(() {
      _selectedStatus = null;
      _currentPage = 1;
      _selectedIds.clear();
    });
    _loadJobList();
  }

  Future<void> _deleteJob(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteJob} "${job.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final jobApi = ref.read(jobApiProvider);
        final response = await jobApi.deleteJob(job.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadJobList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteBatch() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text(S.current.confirmDeleteBatch),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final jobApi = ref.read(jobApiProvider);
        final response = await jobApi.deleteJobList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            setState(() => _selectedIds.clear());
            _loadJobList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(Job job) async {
    final newStatus = job.status == JobStatus.stop
        ? JobStatus.normal
        : JobStatus.stop;
    final statusText = newStatus == JobStatus.normal
        ? S.current.jobStart
        : S.current.jobPause;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirm),
        content: Text('$statusText "${job.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final jobApi = ref.read(jobApiProvider);
        final response = await jobApi.updateJobStatus(job.id!, newStatus);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.operationSuccess)),
            );
            _loadJobList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.operationFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _triggerJob(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirm),
        content: Text('${S.current.jobExecute} "${job.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final jobApi = ref.read(jobApiProvider);
        final response = await jobApi.triggerJob(job.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.operationSuccess)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.operationFailed}: $e')),
          );
        }
      }
    }
  }

  void _viewLog(Job? job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobLogPage(jobId: job?.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          JobSearchForm(
            nameController: _nameController,
            handlerNameController: _handlerNameController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (value) => setState(() => _selectedStatus = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          JobActionButtons(
            onAdd: () => showJobFormDialog(
              context,
              ref: ref,
              onSuccess: _loadJobList,
            ),
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.current.featureNotImplemented)),
              );
            },
            onViewLog: () => _viewLog(null),
            hasSelection: _selectedIds.isNotEmpty,
            onDeleteBatch: _deleteBatch,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: JobDataTable(
              jobList: _jobList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadJobList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadJobList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadJobList();
              },
              onEdit: (job) => showJobFormDialog(
                context,
                job: job,
                ref: ref,
                onSuccess: _loadJobList,
              ),
              onDelete: _deleteJob,
              onUpdateStatus: _updateStatus,
              onTrigger: _triggerJob,
              onDetail: (job) => showJobDetailDialog(
                context,
                jobId: job.id!,
                ref: ref,
              ),
              onViewLog: _viewLog,
              selectedIds: _selectedIds,
              onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
            ),
          ),
        ],
      ),
    );
  }
}