import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/operate_log_api.dart';
import '../../../models/system/operate_log.dart';
import '../../../models/common/page_result.dart';

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
            SnackBar(content: Text(response.msg ?? '加载失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
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
        title: const Text('操作日志详情'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('日志编号', log.id?.toString() ?? '-'),
                if (log.traceId != null && log.traceId!.isNotEmpty)
                  _buildDetailItem('链路追踪', log.traceId!),
                _buildDetailItem('操作人编号', log.userId?.toString() ?? '-'),
                _buildDetailItem('操作人类型', _getUserTypeText(log.userType)),
                _buildDetailItem('操作人名字', log.userName ?? '-'),
                _buildDetailItem('操作人 IP', log.userIp ?? '-'),
                if (log.userAgent != null && log.userAgent!.isNotEmpty)
                  _buildDetailItem('操作人 UA', log.userAgent!),
                _buildDetailItem('操作模块', log.type ?? '-'),
                _buildDetailItem('操作名', log.subType ?? '-'),
                _buildDetailItem('操作内容', log.action ?? '-'),
                if (log.extra != null && log.extra!.isNotEmpty)
                  _buildDetailItem('操作拓展参数', log.extra!),
                _buildDetailItem(
                  '请求 URL',
                  log.requestMethod != null && log.requestUrl != null
                      ? '${log.requestMethod} ${log.requestUrl}'
                      : log.requestUrl ?? '-',
                ),
                _buildDetailItem('操作时间', log.createTime ?? '-'),
                _buildDetailItem('业务编号', log.bizId?.toString() ?? '-'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
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
        return '管理员';
      case 2:
        return '会员';
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
              decoration: const InputDecoration(
                hintText: '操作人',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                hintText: '操作模块',
                prefixIcon: Icon(Icons.folder),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                hintText: '操作名',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                hintText: '操作内容',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                hintText: '业务编号',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  hintText: '操作时间',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  _dateRange != null
                      ? '${_dateRange!.start.toString().substring(0, 10)} ~ ${_dateRange!.end.toString().substring(0, 10)}'
                      : '选择时间范围',
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
            label: const Text('搜索'),
          ),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
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
        header: Text('操作日志列表 (共 $_totalCount 条)'),
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
        columns: const [
          DataColumn(label: Text('日志编号')),
          DataColumn(label: Text('操作人')),
          DataColumn(label: Text('操作模块')),
          DataColumn(label: Text('操作名')),
          DataColumn(label: Text('操作内容')),
          DataColumn(label: Text('操作时间')),
          DataColumn(label: Text('业务编号')),
          DataColumn(label: Text('操作IP')),
          DataColumn(label: Text('操作')),
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
            label: const Text('详情'),
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