import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/login_log_api.dart';
import '../../../models/system/login_log.dart';
import '../../../models/common/page_result.dart';
import '../../../i18n/i18n.dart';

/// 登录日志管理页面
class LoginLogPage extends ConsumerStatefulWidget {
  const LoginLogPage({super.key});

  @override
  ConsumerState<LoginLogPage> createState() => _LoginLogPageState();
}

class _LoginLogPageState extends ConsumerState<LoginLogPage> {
  final _usernameController = TextEditingController();
  final _userIpController = TextEditingController();
  DateTimeRange? _dateRange;

  List<LoginLog> _logs = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIpController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_usernameController.text.isNotEmpty)
          'username': _usernameController.text,
        if (_userIpController.text.isNotEmpty) 'userIp': _userIpController.text,
        if (_dateRange != null) ...{
          'createTime': <String?>[
            _dateRange!.start.toIso8601String(),
            _dateRange!.end.toIso8601String(),
          ],
        },
      };

      final api = ref.read(loginLogApiProvider);
      final response = await api.getLoginLogPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _logs = response.data!.list;
          _totalCount = response.data!.total;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.loginLog_loadFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.loginLog_loadFailed}: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _search() {
    _currentPage = 1;
    _loadData();
  }

  void _reset() {
    _usernameController.clear();
    _userIpController.clear();
    setState(() {
      _dateRange = null;
    });
    _currentPage = 1;
    _loadData();
  }

  void _showDetail(LoginLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.loginLog_detailTitle),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(S.current.loginLog_logId, log.id?.toString() ?? '-'),
              _buildDetailItem(S.current.loginLog_logType, _getLogTypeText(log.logType)),
              _buildDetailItem(S.current.loginLog_username, log.username ?? '-'),
              _buildDetailItem(S.current.loginLog_loginAddress, log.userIp ?? '-'),
              _buildDetailItem(S.current.loginLog_browser, log.userAgent ?? '-'),
              _buildDetailItem(S.current.loginLog_loginResult, _getResultText(log.result)),
              _buildDetailItem(S.current.loginLog_loginDate, log.createTime ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.common_close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  String _getLogTypeText(int? logType) {
    switch (logType) {
      case 1:
        return S.current.loginLog_typePassword;
      case 2:
        return S.current.loginLog_typeSocial;
      default:
        return '-';
    }
  }

  String _getResultText(int? result) {
    switch (result) {
      case 0:
        return S.current.common_success;
      case 1:
        return S.current.common_failed;
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户名称搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: S.current.loginLog_username,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 登录地址搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _userIpController,
              decoration: InputDecoration(
                hintText: S.current.loginLog_loginAddress,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 时间范围选择
          SizedBox(
            width: 280,
            child: InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (range != null) {
                  setState(() {
                    _dateRange = range;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: S.current.loginLog_loginTime,
                  prefixIcon: const Icon(Icons.date_range),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  _dateRange != null
                      ? '${_dateRange!.start.toString().substring(0, 10)} ~ ${_dateRange!.end.toString().substring(0, 10)}'
                      : S.current.common_selectTimeRange,
                  style: TextStyle(
                    color: _dateRange != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.common_search),
          ),
          const SizedBox(width: 8),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.common_reset),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text('${S.current.loginLog_list} (${S.current.cacl_common_totalCount(_totalCount)})'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          _currentPage = page ~/ _pageSize + 1;
          _loadData();
        },
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
            });
            _loadData();
          }
        },
        columns: [
          DataColumn(label: Text(S.current.loginLog_logId)),
          DataColumn(label: Text(S.current.loginLog_logType)),
          DataColumn(label: Text(S.current.loginLog_username)),
          DataColumn(label: Text(S.current.loginLog_loginAddress)),
          DataColumn(label: Text(S.current.loginLog_browser)),
          DataColumn(label: Text(S.current.loginLog_loginResult)),
          DataColumn(label: Text(S.current.loginLog_loginDate)),
          DataColumn(label: Text(S.current.common_operation)),
        ],
        source: _LoginLogDataSource(_logs, context, _showDetail),
      ),
    );
  }
}

/// 登录日志数据源
class _LoginLogDataSource extends DataTableSource {
  final List<LoginLog> logs;
  final BuildContext context;
  final void Function(LoginLog) onShowDetail;

  _LoginLogDataSource(this.logs, this.context, this.onShowDetail);

  @override
  int get rowCount => logs.length;

  @override
  DataRow getRow(int index) {
    final log = logs[index];
    return DataRow(
      cells: [
        DataCell(Text(log.id?.toString() ?? '-')),
        DataCell(_buildLogTypeCell(log.logType)),
        DataCell(Text(log.username ?? '-')),
        DataCell(Text(log.userIp ?? '-')),
        DataCell(
          Tooltip(
            message: log.userAgent ?? '-',
            child: SizedBox(
              width: 150,
              child: Text(
                log.userAgent ?? '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(_buildResultCell(log.result)),
        DataCell(Text(log.createTime ?? '-')),
        DataCell(
          TextButton.icon(
            onPressed: () => onShowDetail(log),
            icon: const Icon(Icons.visibility, size: 18),
            label: Text(S.current.common_detail),
          ),
        ),
      ],
    );
  }

  Widget _buildLogTypeCell(int? logType) {
    String text;
    Color color;

    switch (logType) {
      case 1:
        text = S.current.loginLog_typePassword;
        color = Colors.blue;
        break;
      case 2:
        text = S.current.loginLog_typeSocial;
        color = Colors.purple;
        break;
      default:
        text = '-';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildResultCell(int? result) {
    String text;
    Color color;

    switch (result) {
      case 0:
        text = S.current.common_success;
        color = Colors.green;
        break;
      case 1:
        text = S.current.common_failed;
        color = Colors.red;
        break;
      default:
        text = '-';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}