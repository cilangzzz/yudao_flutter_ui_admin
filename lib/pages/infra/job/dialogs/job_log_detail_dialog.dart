import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/job_log_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 任务日志详情对话框
class JobLogDetailDialog extends StatefulWidget {
  final int logId;
  final WidgetRef ref;

  const JobLogDetailDialog({
    super.key,
    required this.logId,
    required this.ref,
  });

  @override
  State<JobLogDetailDialog> createState() => _JobLogDetailDialogState();
}

class _JobLogDetailDialogState extends State<JobLogDetailDialog> {
  JobLog? _log;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jobLogApi = widget.ref.read(jobLogApiProvider);
      final response = await jobLogApi.getJobLog(widget.logId);

      if (mounted) {
        setState(() {
          _log = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.jobLogDetail),
      content: SizedBox(
        width: 500,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.close),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text('${S.current.loadFailed}: $_error'),
        ),
      );
    }

    if (_log == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(S.current.noData)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(S.current.logId, _log!.id?.toString() ?? '-'),
          _buildItem(S.current.jobId, _log!.jobId.toString()),
          _buildItem(S.current.handlerName, _log!.handlerName),
          _buildItem(S.current.handlerParam, _log!.handlerParam.isEmpty
              ? '-'
              : _log!.handlerParam),
          _buildItem(S.current.executeIndex, _log!.executeIndex),
          _buildItem(S.current.executeTime, _formatExecuteTime()),
          _buildItem(S.current.duration, '${_log!.duration} ${S.current.milliseconds}'),
          _buildItem(S.current.status, _log!.status == JobLogStatus.success
              ? S.current.jobLogStatusSuccess
              : S.current.jobLogStatusFailure),
          _buildItem(S.current.result, _log!.result ?? '-'),
        ],
      ),
    );
  }

  String _formatExecuteTime() {
    if (_log!.beginTime != null && _log!.endTime != null) {
      return '${_log!.beginTime} ~ ${_log!.endTime}';
    }
    return _log!.beginTime ?? '-';
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
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
}

/// 显示日志详情对话框的便捷方法
void showJobLogDetailDialog(
  BuildContext context, {
  required int logId,
  required WidgetRef ref,
}) {
  showDialog(
    context: context,
    builder: (context) => JobLogDetailDialog(
      logId: logId,
      ref: ref,
    ),
  );
}