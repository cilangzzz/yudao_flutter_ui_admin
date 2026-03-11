import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/login_log_api.dart';
import '../../../core/api_client.dart';
import '../../../models/system/login_log.dart';
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
  String? _error;

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
      _error = null;
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
        setState(() {
          _error = response.msg ?? S.current.loginLog_loadFailed;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
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

  Future<void> _exportLogs() async {
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_usernameController.text.isNotEmpty) {
        params['username'] = _usernameController.text;
      }
      if (_userIpController.text.isNotEmpty) {
        params['userIp'] = _userIpController.text;
      }
      if (_dateRange != null) {
        params['createTime'] = [
          _dateRange!.start.toIso8601String(),
          _dateRange!.end.toIso8601String(),
        ];
      }

      final response = await dio.get<List<int>>(
        '/system/login-log/export-excel',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      // response.data contains the Excel file bytes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.exportSuccess)),
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
            child: Text(S.current.close),
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
        return S.current.success;
      case 1:
        return S.current.failed;
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

          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _exportLogs,
            icon: const Icon(Icons.download, size: 20),
            label: Text(S.current.export),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 用户名称搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: S.current.loginLog_username,
                prefixIcon: const Icon(Icons.person, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 登录地址搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _userIpController,
              decoration: InputDecoration(
                hintText: S.current.loginLog_loginAddress,
                prefixIcon: const Icon(Icons.location_on, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

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
                  prefixIcon: const Icon(Icons.date_range, size: 20),
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

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.loginLog_list),
              const Spacer(),
              Text('${S.current.total}: $_totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text(S.current.loginLog_logId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_logType),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_username),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_loginAddress),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_browser),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_loginResult),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.loginLog_loginDate),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                  numeric: true,
                ),
              ],
              rows: _logs.map((log) {
                return DataRow2(
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
                      TextButton(
                        onPressed: () => _showDetail(log),
                        child: Text(S.current.detail),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 每页行数选择
              Row(
                children: [
                  Text('${S.current.pageSize}: '),
                  DropdownButton<int>(
                    value: _pageSize,
                    items: [10, 20, 50, 100].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _pageSize = value;
                          _currentPage = 1;
                        });
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // 分页导航
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadData();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadData();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
        text = S.current.success;
        color = Colors.green;
        break;
      case 1:
        text = S.current.failed;
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
}