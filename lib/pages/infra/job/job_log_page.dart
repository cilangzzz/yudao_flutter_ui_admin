import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/job_log_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/pages/infra/job/widgets/job_log_search_form.dart';
import 'package:yudao_flutter_ui_admin/pages/infra/job/widgets/job_log_data_table.dart';
import 'package:yudao_flutter_ui_admin/pages/infra/job/dialogs/job_log_detail_dialog.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 任务日志页面
class JobLogPage extends ConsumerStatefulWidget {
  final int? jobId;

  const JobLogPage({super.key, this.jobId});

  @override
  ConsumerState<JobLogPage> createState() => _JobLogPageState();
}

class _JobLogPageState extends ConsumerState<JobLogPage> {
  final _handlerNameController = TextEditingController();
  int? _selectedStatus;

  List<JobLog> _logList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogList();
  }

  @override
  void dispose() {
    _handlerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLogList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobLogApi = ref.read(jobLogApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_handlerNameController.text.isNotEmpty) 'handlerName': _handlerNameController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (widget.jobId != null) 'jobId': widget.jobId,
      };

      final response = await jobLogApi.getJobLogPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _logList = response.data!.list;
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
    _loadLogList();
  }

  void _reset() {
    _handlerNameController.clear();
    setState(() {
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadLogList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.jobLogList),
      ),
      body: Column(
        children: [
          // 搜索栏
          JobLogSearchForm(
            handlerNameController: _handlerNameController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (value) => setState(() => _selectedStatus = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: JobLogDataTable(
              logList: _logList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadLogList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadLogList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadLogList();
              },
              onDetail: (log) => showJobLogDetailDialog(
                context,
                logId: log.id!,
                ref: ref,
              ),
            ),
          ),
        ],
      ),
    );
  }
}