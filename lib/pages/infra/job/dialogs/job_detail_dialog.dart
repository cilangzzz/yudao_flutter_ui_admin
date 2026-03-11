import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/job_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

import '../../../../models/common/api_response.dart';

/// 定时任务详情对话框
class JobDetailDialog extends StatefulWidget {
  final int jobId;
  final WidgetRef ref;

  const JobDetailDialog({
    super.key,
    required this.jobId,
    required this.ref,
  });

  @override
  State<JobDetailDialog> createState() => _JobDetailDialogState();
}

class _JobDetailDialogState extends State<JobDetailDialog> {
  Job? _job;
  List<String>? _nextTimes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jobApi = widget.ref.read(jobApiProvider);

      // 并行加载任务详情和下次执行时间
      final results = await Future.wait([
        jobApi.getJob(widget.jobId),
        jobApi.getJobNextTimes(widget.jobId),
      ]);

      if (mounted) {
        final jobResponse = results[0] as ApiResponse<Job>;
        final nextTimesResponse = results[1] as ApiResponse<List<String>>;
        setState(() {
          _job = jobResponse.data;
          _nextTimes = nextTimesResponse.data;
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
      title: Text(S.current.jobDetail),
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

    if (_job == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(S.current.noData)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(S.current.jobId, _job!.id?.toString() ?? '-'),
          _buildItem(S.current.jobName, _job!.name),
          _buildItem(S.current.status, _job!.status == JobStatus.normal
              ? S.current.jobStatusNormal
              : S.current.jobStatusStop),
          _buildItem(S.current.handlerName, _job!.handlerName),
          _buildItem(S.current.handlerParam, _job!.handlerParam.isEmpty
              ? '-'
              : _job!.handlerParam),
          _buildItem(S.current.cronExpression, _job!.cronExpression),
          _buildItem(S.current.retryCount, _job!.retryCount.toString()),
          _buildItem(S.current.retryInterval, '${_job!.retryInterval} ${S.current.milliseconds}'),
          _buildItem(S.current.monitorTimeout, _job!.monitorTimeout != null && _job!.monitorTimeout! > 0
              ? '${_job!.monitorTimeout} ${S.current.milliseconds}'
              : S.current.notEnabled),
          _buildNextTimes(),
        ],
      ),
    );
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
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTimes() {
    if (_nextTimes == null || _nextTimes!.isEmpty) {
      return _buildItem(S.current.nextExecuteTime, S.current.noNextExecuteTime);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.nextExecuteTime,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...(_nextTimes!.take(5).map((time) => Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(time),
              ],
            ),
          ))),
        ],
      ),
    );
  }
}

/// 显示任务详情对话框的便捷方法
void showJobDetailDialog(
  BuildContext context, {
  required int jobId,
  required WidgetRef ref,
}) {
  showDialog(
    context: context,
    builder: (context) => JobDetailDialog(
      jobId: jobId,
      ref: ref,
    ),
  );
}