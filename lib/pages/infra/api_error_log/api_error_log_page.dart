import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/api_error_log_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_error_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/api_error_log_search_form.dart';
import 'widgets/api_error_log_data_table.dart';
import 'dialogs/api_error_log_detail_dialog.dart';

/// API 错误日志页面
class ApiErrorLogPage extends ConsumerStatefulWidget {
  const ApiErrorLogPage({super.key});

  @override
  ConsumerState<ApiErrorLogPage> createState() => _ApiErrorLogPageState();
}

class _ApiErrorLogPageState extends ConsumerState<ApiErrorLogPage> {
  final _userIdController = TextEditingController();
  final _applicationNameController = TextEditingController();
  int? _selectedUserType;
  int? _selectedProcessStatus;
  DateTimeRange? _dateRange;

  List<ApiErrorLog> _logList = [];
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
    _userIdController.dispose();
    _applicationNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLogList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiErrorLogApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_userIdController.text.isNotEmpty) 'userId': _userIdController.text,
        if (_selectedUserType != null) 'userType': _selectedUserType,
        if (_applicationNameController.text.isNotEmpty) 'applicationName': _applicationNameController.text,
        if (_dateRange != null) ...{
          'exceptionTime': _dateRange!.start.toString().split(' ').first,
        },
        if (_selectedProcessStatus != null) 'processStatus': _selectedProcessStatus,
      };

      final response = await api.getApiErrorLogPage(params);

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
    _userIdController.clear();
    _applicationNameController.clear();
    setState(() {
      _selectedUserType = null;
      _selectedProcessStatus = null;
      _dateRange = null;
      _currentPage = 1;
    });
    _loadLogList();
  }

  Future<void> _exportLogList() async {
    try {
      final api = ref.read(apiErrorLogApiProvider);
      final params = {
        if (_userIdController.text.isNotEmpty) 'userId': _userIdController.text,
        if (_selectedUserType != null) 'userType': _selectedUserType,
        if (_applicationNameController.text.isNotEmpty) 'applicationName': _applicationNameController.text,
        if (_dateRange != null) ...{
          'exceptionTime': _dateRange!.start.toString().split(' ').first,
        },
        if (_selectedProcessStatus != null) 'processStatus': _selectedProcessStatus,
      };

      final response = await api.exportApiErrorLog(params);
      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.exportSuccess)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg ?? S.current.exportFailed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.exportFailed}: $e')),
        );
      }
    }
  }

  Future<void> _processLog(ApiErrorLog log, int processStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirm),
        content: Text(
          processStatus == 1
              ? S.current.confirmProcessDone
              : S.current.confirmProcessIgnore,
        ),
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
        final api = ref.read(apiErrorLogApiProvider);
        final response = await api.updateApiErrorLogStatus(log.id!, processStatus);

        if (response.isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.operationSuccess)),
          );
          _loadLogList();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          ApiErrorLogSearchForm(
            userIdController: _userIdController,
            applicationNameController: _applicationNameController,
            selectedUserType: _selectedUserType,
            selectedProcessStatus: _selectedProcessStatus,
            dateRange: _dateRange,
            onUserTypeChanged: (value) => setState(() => _selectedUserType = value),
            onProcessStatusChanged: (value) => setState(() => _selectedProcessStatus = value),
            onDateRangeChanged: (value) => setState(() => _dateRange = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _exportLogList,
                  icon: const Icon(Icons.download),
                  label: Text(S.current.export),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: ApiErrorLogDataTable(
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
              onDetail: (log) => showApiErrorLogDetailDialog(context, log: log),
              onProcess: _processLog,
            ),
          ),
        ],
      ),
    );
  }
}