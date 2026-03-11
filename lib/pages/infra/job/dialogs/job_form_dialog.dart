import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/job_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 定时任务表单对话框（新增/编辑任务）
class JobFormDialog extends StatefulWidget {
  final Job? job;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const JobFormDialog({
    super.key,
    this.job,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends State<JobFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _handlerNameController;
  late final TextEditingController _handlerParamController;
  late final TextEditingController _cronExpressionController;
  late final TextEditingController _retryCountController;
  late final TextEditingController _retryIntervalController;
  late final TextEditingController _monitorTimeoutController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.job?.name ?? '');
    _handlerNameController = TextEditingController(text: widget.job?.handlerName ?? '');
    _handlerParamController = TextEditingController(text: widget.job?.handlerParam ?? '');
    _cronExpressionController = TextEditingController(text: widget.job?.cronExpression ?? '');
    _retryCountController = TextEditingController(text: (widget.job?.retryCount ?? 0).toString());
    _retryIntervalController = TextEditingController(text: (widget.job?.retryInterval ?? 0).toString());
    _monitorTimeoutController = TextEditingController(text: (widget.job?.monitorTimeout ?? 0).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handlerNameController.dispose();
    _handlerParamController.dispose();
    _cronExpressionController.dispose();
    _retryCountController.dispose();
    _retryIntervalController.dispose();
    _monitorTimeoutController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _handlerNameController.text.isEmpty ||
        _cronExpressionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobData = Job(
        id: widget.job?.id,
        name: _nameController.text,
        status: widget.job?.status ?? JobStatus.normal,
        handlerName: _handlerNameController.text,
        handlerParam: _handlerParamController.text,
        cronExpression: _cronExpressionController.text,
        retryCount: int.tryParse(_retryCountController.text) ?? 0,
        retryInterval: int.tryParse(_retryIntervalController.text) ?? 0,
        monitorTimeout: int.tryParse(_monitorTimeoutController.text),
      );

      final jobApi = widget.ref.read(jobApiProvider);
      ApiResponse<void> response;

      if (widget.job == null) {
        response = await jobApi.createJob(jobData);
      } else {
        response = await jobApi.updateJob(jobData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.job == null ? S.current.addSuccess : S.current.editSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.job == null ? S.current.addJob : S.current.editJob),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.jobName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _handlerNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.handlerName} *',
                  border: const OutlineInputBorder(),
                  hintText: S.current.handlerNamePlaceholder,
                ),
                enabled: widget.job == null,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _handlerParamController,
                decoration: InputDecoration(
                  labelText: S.current.handlerParam,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cronExpressionController,
                decoration: InputDecoration(
                  labelText: '${S.current.cronExpression} *',
                  border: const OutlineInputBorder(),
                  hintText: S.current.cronExpressionPlaceholder,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _retryCountController,
                decoration: InputDecoration(
                  labelText: S.current.retryCount,
                  border: const OutlineInputBorder(),
                  hintText: S.current.retryCountPlaceholder,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _retryIntervalController,
                decoration: InputDecoration(
                  labelText: S.current.retryInterval,
                  border: const OutlineInputBorder(),
                  hintText: S.current.retryIntervalPlaceholder,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _monitorTimeoutController,
                decoration: InputDecoration(
                  labelText: S.current.monitorTimeout,
                  border: const OutlineInputBorder(),
                  hintText: S.current.monitorTimeoutPlaceholder,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示任务表单对话框的便捷方法
void showJobFormDialog(
  BuildContext context, {
  Job? job,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => JobFormDialog(
      job: job,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}