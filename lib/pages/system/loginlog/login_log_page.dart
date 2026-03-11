import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/login_log_api.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/system/login_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'package:yudao_flutter_ui_admin/pages/system/common/widgets/date_range_picker.dart';

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
    final isMobile = DeviceUIMode.isMobile(context);

    if (isMobile) {
      _showDetailBottomSheet(log);
    } else {
      _showDetailDialog(log);
    }
  }

  void _showDetailDialog(LoginLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.loginLog_detailTitle),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
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

  void _showDetailBottomSheet(LoginLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    S.current.loginLog_detailTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
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
            ),
          ],
        ),
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
    final isMobile = DeviceUIMode.isMobile(context);

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
            child: isMobile
                ? _buildMobileListView(context)
                : _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
    final isMobile = DeviceUIMode.isMobile(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 用户名称搜索
              SizedBox(
                width: isMobile ? constraints.maxWidth : 200,
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
              if (!isMobile)
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
              DateRangePicker(
                initialDateRange: _dateRange,
                hintText: S.current.loginLog_loginTime,
                width: isMobile ? constraints.maxWidth : 280,
                onDateRangeChanged: (range) {
                  setState(() {
                    _dateRange = range;
                  });
                },
              ),

              // 搜索和重置按钮
              if (isMobile)
                SizedBox(
                  width: constraints.maxWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _search,
                          icon: const Icon(Icons.search, size: 20),
                          label: Text(S.current.search),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: Text(S.current.reset),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileListView(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: Text(S.current.retry)),
            ],
          ),
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        // 列表头
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(S.current.loginLog_list),
              const Spacer(),
              Text('${S.current.total}: $_totalCount'),
            ],
          ),
        ),
        // 列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              final log = _logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    log.username ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    log.createTime ?? '-',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: _buildResultChip(log.result),
                  children: [
                    _buildMobileDetailRow(S.current.loginLog_logId, log.id?.toString() ?? '-'),
                    _buildMobileDetailRow(S.current.loginLog_logType, _getLogTypeText(log.logType)),
                    _buildMobileDetailRow(S.current.loginLog_loginAddress, log.userIp ?? '-'),
                    _buildMobileDetailRow(S.current.loginLog_browser, log.userAgent ?? '-'),
                    _buildMobileDetailRow(S.current.loginLog_loginDate, log.createTime ?? '-'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showDetail(log),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(S.current.detail),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 分页控件
        _buildMobilePagination(),
      ],
    );
  }

  Widget _buildMobileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultChip(int? result) {
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildMobilePagination() {
    final totalPages = (_totalCount / _pageSize).ceil();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$_currentPage / $totalPages'),
          ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DataTable2(
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
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.15,
                              ),
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
                );
              },
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildDesktopPagination(),
        ],
      ),
    );
  }

  Widget _buildDesktopPagination() {
    return Row(
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
        color: color.withValues(alpha: 0.1),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}