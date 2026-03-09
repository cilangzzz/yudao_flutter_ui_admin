import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/operate_log_api.dart';
import '../../../models/system/operate_log.dart';
import '../../../models/common/page_result.dart';
import '../../../i18n/i18n.dart';

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.operateLog_loadFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operateLog_loadFailed}: $e')),
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

  void _showDetail(OperateLog log) {
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
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          // 操作人搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                hintText: S.current.operateLog_userName,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 操作模块搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: S.current.operateLog_module,
                prefixIcon: const Icon(Icons.folder),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 操作名搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _subTypeController,
              decoration: InputDecoration(
                hintText: S.current.operateLog_actionName,
                prefixIcon: const Icon(Icons.label),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 操作内容搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _actionController,
              decoration: InputDecoration(
                hintText: S.current.operateLog_actionContent,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),

          // 业务编号搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _bizIdController,
              decoration: InputDecoration(
                hintText: S.current.operateLog_bizId,
                prefixIcon: const Icon(Icons.tag),
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
                  hintText: S.current.operateLog_operateTime,
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

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.common_search),
          ),

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
        header: Text('${S.current.operateLog_list} (${S.current.common_totalCount})'),
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
          DataColumn(label: Text(S.current.operateLog_logId)),
          DataColumn(label: Text(S.current.operateLog_userName)),
          DataColumn(label: Text(S.current.operateLog_module)),
          DataColumn(label: Text(S.current.operateLog_actionName)),
          DataColumn(label: Text(S.current.operateLog_actionContent)),
          DataColumn(label: Text(S.current.operateLog_operateTime)),
          DataColumn(label: Text(S.current.operateLog_bizId)),
          DataColumn(label: Text(S.current.operateLog_userIp)),
          DataColumn(label: Text(S.current.common_operation)),
        ],
        source: _OperateLogDataSource(_logs, context, _showDetail),
      ),
    );
  }
}

/// 操作日志数据源
class _OperateLogDataSource extends DataTableSource {
  final List<OperateLog> logs;
  final BuildContext context;
  final void Function(OperateLog) onShowDetail;

  _OperateLogDataSource(this.logs, this.context, this.onShowDetail);

  @override
  int get rowCount => logs.length;

  @override
  DataRow getRow(int index) {
    final log = logs[index];
    return DataRow(
      cells: [
        DataCell(Text(log.id?.toString() ?? '-')),
        DataCell(Text(log.userName ?? '-')),
        DataCell(Text(log.type ?? '-')),
        DataCell(Text(log.subType ?? '-')),
        DataCell(
          Tooltip(
            message: log.action ?? '-',
            child: SizedBox(
              width: 150,
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
          TextButton.icon(
            onPressed: () => onShowDetail(log),
            icon: const Icon(Icons.visibility, size: 18),
            label: Text(S.current.common_detail),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}