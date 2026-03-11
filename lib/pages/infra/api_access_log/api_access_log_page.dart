import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/api_access_log_api.dart';
import '../../../models/infra/api_access_log.dart';
import '../../../i18n/i18n.dart';
import 'widgets/api_access_log_search_form.dart';
import 'widgets/api_access_log_data_table.dart';
import 'dialogs/api_access_log_detail_dialog.dart';

/// API 访问日志页面
class ApiAccessLogPage extends ConsumerStatefulWidget {
  const ApiAccessLogPage({super.key});

  @override
  ConsumerState<ApiAccessLogPage> createState() => _ApiAccessLogPageState();
}

class _ApiAccessLogPageState extends ConsumerState<ApiAccessLogPage> {
  final _userIdController = TextEditingController();
  final _applicationNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _resultCodeController = TextEditingController();
  int? _selectedUserType;
  DateTimeRange? _dateRange;

  List<ApiAccessLog> _logList = [];
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
    _durationController.dispose();
    _resultCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadLogList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiAccessLogApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_userIdController.text.isNotEmpty) 'userId': _userIdController.text,
        if (_selectedUserType != null) 'userType': _selectedUserType,
        if (_applicationNameController.text.isNotEmpty) 'applicationName': _applicationNameController.text,
        if (_dateRange != null) ...{
          'beginTime': _dateRange!.start.toString().split(' ').first,
          'endTime': _dateRange!.end.toString().split(' ').first,
        },
        if (_durationController.text.isNotEmpty) 'duration': _durationController.text,
        if (_resultCodeController.text.isNotEmpty) 'resultCode': _resultCodeController.text,
      };

      final response = await api.getApiAccessLogPage(params);

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
    _durationController.clear();
    _resultCodeController.clear();
    setState(() {
      _selectedUserType = null;
      _dateRange = null;
      _currentPage = 1;
    });
    _loadLogList();
  }

  Future<void> _exportLogList() async {
    try {
      final api = ref.read(apiAccessLogApiProvider);
      final params = {
        if (_userIdController.text.isNotEmpty) 'userId': _userIdController.text,
        if (_selectedUserType != null) 'userType': _selectedUserType,
        if (_applicationNameController.text.isNotEmpty) 'applicationName': _applicationNameController.text,
        if (_dateRange != null) ...{
          'beginTime': _dateRange!.start.toString().split(' ').first,
          'endTime': _dateRange!.end.toString().split(' ').first,
        },
        if (_durationController.text.isNotEmpty) 'duration': _durationController.text,
        if (_resultCodeController.text.isNotEmpty) 'resultCode': _resultCodeController.text,
      };

      final response = await api.exportApiAccessLog(params);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          ApiAccessLogSearchForm(
            userIdController: _userIdController,
            applicationNameController: _applicationNameController,
            durationController: _durationController,
            resultCodeController: _resultCodeController,
            selectedUserType: _selectedUserType,
            dateRange: _dateRange,
            onUserTypeChanged: (value) => setState(() => _selectedUserType = value),
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
            child: ApiAccessLogDataTable(
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
              onDetail: (log) => showApiAccessLogDetailDialog(context, log: log),
            ),
          ),
        ],
      ),
    );
  }
}