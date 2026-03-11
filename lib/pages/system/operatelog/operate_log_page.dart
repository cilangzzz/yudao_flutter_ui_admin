import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/operate_log_api.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/system/operate_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'package:yudao_flutter_ui_admin/pages/system/common/widgets/date_range_picker.dart';

/// 操作日志管理页面
class OperateLogPage extends ConsumerStatefulWidget {
  const OperateLogPage({super.key});

  @override
  ConsumerState<OperateLogPage> createState() => _OperateLogPageState();
}

class _OperateLogPageState extends ConsumerState<OperateLogPage> {
  final _userNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _subTypeController = TextEditingController();
  final _actionController = TextEditingController();
  final _bizIdController = TextEditingController();
  DateTimeRange? _dateRange;

  List<OperateLog> _logs = [];
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
    _userNameController.dispose();
    _typeController.dispose();
    _subTypeController.dispose();
    _actionController.dispose();
    _bizIdController.dispose();
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
        if (_userNameController.text.isNotEmpty)
          'userName': _userNameController.text,
        if (_typeController.text.isNotEmpty) 'type': _typeController.text,
        if (_subTypeController.text.isNotEmpty) 'subType': _subTypeController.text,
        if (_actionController.text.isNotEmpty) 'action': _actionController.text,
        if (_bizIdController.text.isNotEmpty) 'bizId': _bizIdController.text,
        if (_dateRange != null) ...{
          'createTime': <String?>[
            _dateRange!.start.toIso8601String(),
            _dateRange!.end.toIso8601String(),
          ],
        },
      };

      final api = ref.read(operateLogApiProvider);
      final response = await api.getOperateLogPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _logs = response.data!.list;
          _totalCount = response.data!.total;
        });
      } else {
        setState(() {
          _error = response.msg ?? S.current.operateLog_loadFailed;
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
    _userNameController.clear();
    _typeController.clear();
    _subTypeController.clear();
    _actionController.clear();
    _bizIdController.clear();
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
      if (_userNameController.text.isNotEmpty) {
        params['userName'] = _userNameController.text;
      }
      if (_typeController.text.isNotEmpty) {
        params['type'] = _typeController.text;
      }
      if (_subTypeController.text.isNotEmpty) {
        params['subType'] = _subTypeController.text;
      }
      if (_actionController.text.isNotEmpty) {
        params['action'] = _actionController.text;
      }
      if (_bizIdController.text.isNotEmpty) {
        params['bizId'] = _bizIdController.text;
      }
      if (_dateRange != null) {
        params['createTime'] = [
          _dateRange!.start.toIso8601String(),
          _dateRange!.end.toIso8601String(),
        ];
      }

      final response = await dio.get<List<int>>(
        '/system/operate-log/export-excel',
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

  void _showDetail(OperateLog log) {
    final isMobile = DeviceUIMode.isMobile(context);

    if (isMobile) {
      _showDetailBottomSheet(log);
    } else {
      _showDetailDialog(log);
    }
  }

  void _showDetailDialog(OperateLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.operateLog_detailTitle),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(S.current.operateLog_logId, log.id?.toString() ?? '-'),
                if (log.traceId != null && log.traceId!.isNotEmpty)
                  _buildDetailItem(S.current.operateLog_traceId, log.traceId!),
                _buildDetailItem(S.current.operateLog_userId, log.userId?.toString() ?? '-'),
                _buildDetailItem(S.current.operateLog_userType, _getUserTypeText(log.userType)),
                _buildDetailItem(S.current.operateLog_userName, log.userName ?? '-'),
                _buildDetailItem(S.current.operateLog_userIp, log.userIp ?? '-'),
                if (log.userAgent != null && log.userAgent!.isNotEmpty)
                  _buildDetailItem(S.current.operateLog_userAgent, log.userAgent!),
                _buildDetailItem(S.current.operateLog_module, log.type ?? '-'),
                _buildDetailItem(S.current.operateLog_actionName, log.subType ?? '-'),
                _buildDetailItem(S.current.operateLog_actionContent, log.action ?? '-'),
                if (log.extra != null && log.extra!.isNotEmpty)
                  _buildDetailItem(S.current.operateLog_extra, log.extra!),
                _buildDetailItem(
                  S.current.operateLog_requestUrl,
                  log.requestMethod != null && log.requestUrl != null
                      ? '${log.requestMethod} ${log.requestUrl}'
                      : log.requestUrl ?? '-',
                ),
                _buildDetailItem(S.current.operateLog_operateTime, log.createTime ?? '-'),
                _buildDetailItem(S.current.operateLog_bizId, log.bizId?.toString() ?? '-'),
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

  void _showDetailBottomSheet(OperateLog log) {
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
                    S.current.operateLog_detailTitle,
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
                    _buildDetailItem(S.current.operateLog_logId, log.id?.toString() ?? '-'),
                    if (log.traceId != null && log.traceId!.isNotEmpty)
                      _buildDetailItem(S.current.operateLog_traceId, log.traceId!),
                    _buildDetailItem(S.current.operateLog_userId, log.userId?.toString() ?? '-'),
                    _buildDetailItem(S.current.operateLog_userType, _getUserTypeText(log.userType)),
                    _buildDetailItem(S.current.operateLog_userName, log.userName ?? '-'),
                    _buildDetailItem(S.current.operateLog_userIp, log.userIp ?? '-'),
                    if (log.userAgent != null && log.userAgent!.isNotEmpty)
                      _buildDetailItem(S.current.operateLog_userAgent, log.userAgent!),
                    _buildDetailItem(S.current.operateLog_module, log.type ?? '-'),
                    _buildDetailItem(S.current.operateLog_actionName, log.subType ?? '-'),
                    _buildDetailItem(S.current.operateLog_actionContent, log.action ?? '-'),
                    if (log.extra != null && log.extra!.isNotEmpty)
                      _buildDetailItem(S.current.operateLog_extra, log.extra!),
                    _buildDetailItem(
                      S.current.operateLog_requestUrl,
                      log.requestMethod != null && log.requestUrl != null
                          ? '${log.requestMethod} ${log.requestUrl}'
                          : log.requestUrl ?? '-',
                    ),
                    _buildDetailItem(S.current.operateLog_operateTime, log.createTime ?? '-'),
                    _buildDetailItem(S.current.operateLog_bizId, log.bizId?.toString() ?? '-'),
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(int? userType) {
    switch (userType) {
      case 1:
        return S.current.operateLog_userTypeAdmin;
      case 2:
        return S.current.operateLog_userTypeMember;
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
          // 计算每行可以放置的搜索字段数量
          final fieldWidth = isMobile ? constraints.maxWidth : 180.0;

          return Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 操作人搜索
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    hintText: S.current.operateLog_userName,
                    prefixIcon: const Icon(Icons.person, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),

              // 操作模块搜索
              if (!isMobile)
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      hintText: S.current.operateLog_module,
                      prefixIcon: const Icon(Icons.folder, size: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),

              // 操作名搜索
              if (!isMobile)
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _subTypeController,
                    decoration: InputDecoration(
                      hintText: S.current.operateLog_actionName,
                      prefixIcon: const Icon(Icons.label, size: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),

              // 操作内容搜索
              if (!isMobile)
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _actionController,
                    decoration: InputDecoration(
                      hintText: S.current.operateLog_actionContent,
                      prefixIcon: const Icon(Icons.description, size: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),

              // 业务编号搜索
              if (!isMobile)
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _bizIdController,
                    decoration: InputDecoration(
                      hintText: S.current.operateLog_bizId,
                      prefixIcon: const Icon(Icons.tag, size: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),

              // 时间范围选择
              DateRangePicker(
                initialDateRange: _dateRange,
                hintText: S.current.operateLog_operateTime,
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
              Text(S.current.operateLog_list),
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
                    log.userName ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.type ?? '-',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      Text(
                        log.createTime ?? '-',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                  children: [
                    _buildMobileDetailRow(S.current.operateLog_logId, log.id?.toString() ?? '-'),
                    _buildMobileDetailRow(S.current.operateLog_module, log.type ?? '-'),
                    _buildMobileDetailRow(S.current.operateLog_actionName, log.subType ?? '-'),
                    _buildMobileDetailRow(S.current.operateLog_actionContent, log.action ?? '-'),
                    _buildMobileDetailRow(S.current.operateLog_userIp, log.userIp ?? '-'),
                    _buildMobileDetailRow(S.current.operateLog_operateTime, log.createTime ?? '-'),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
              Text(S.current.operateLog_list),
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
                  minWidth: 1000,
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
                      label: Text(S.current.operateLog_logId),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_userName),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_module),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_actionName),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_actionContent),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_operateTime),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_bizId),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.operateLog_userIp),
                      size: ColumnSize.M,
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
                        DataCell(Text(log.userName ?? '-')),
                        DataCell(Text(log.type ?? '-')),
                        DataCell(Text(log.subType ?? '-')),
                        DataCell(
                          Tooltip(
                            message: log.action ?? '-',
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.15,
                              ),
                              child: Text(
                                log.action ?? '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(log.createTime ?? '-')),
                        DataCell(Text(log.bizId?.toString() ?? '-')),
                        DataCell(Text(log.userIp ?? '-')),
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
}