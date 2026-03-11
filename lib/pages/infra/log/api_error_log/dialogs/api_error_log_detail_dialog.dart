import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_error_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 显示 API 错误日志详情弹窗
Future<void> showApiErrorLogDetailDialog(
  BuildContext context, {
  required ApiErrorLog log,
}) async {
  await showDialog(
    context: context,
    builder: (context) => ApiErrorLogDetailDialog(log: log),
  );
}

/// API 错误日志详情弹窗组件
class ApiErrorLogDetailDialog extends StatelessWidget {
  final ApiErrorLog log;

  const ApiErrorLogDetailDialog({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.apiErrorLogDetail),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection(S.current.basicInfo, [
                _buildInfoRow(S.current.logId, log.id?.toString()),
                _buildInfoRow(S.current.traceId, log.traceId),
                _buildInfoRow(S.current.applicationName, log.applicationName),
                _buildInfoRow(S.current.userId, log.userId?.toString()),
                _buildInfoRow(S.current.userType, _getUserTypeText(log.userType)),
                _buildInfoRow(S.current.userIp, log.userIp),
                _buildInfoRow(S.current.userAgent, log.userAgent),
              ]),
              const Divider(),
              _buildSection(S.current.requestInfo, [
                _buildInfoRow(
                  S.current.requestUrl,
                  '${log.requestMethod} ${log.requestUrl}',
                ),
                _buildJsonRow(S.current.requestParams, log.requestParams),
              ]),
              const Divider(),
              _buildSection(S.current.exceptionInfo, [
                _buildInfoRow(S.current.exceptionTime, log.exceptionTime),
                _buildInfoRow(S.current.exceptionName, log.exceptionName),
                _buildInfoRow(S.current.exceptionMessage, log.exceptionMessage, maxLines: 3),
                _buildInfoRow(S.current.exceptionRootCauseMessage, log.exceptionRootCauseMessage, maxLines: 3),
                _buildStackTraceRow(log.exceptionStackTrace),
              ]),
              const Divider(),
              _buildSection(S.current.processInfo, [
                _buildInfoRow(S.current.processStatus, _getProcessStatusText(log.processStatus)),
                if (log.processUserId != null)
                  _buildInfoRow(S.current.processUserId, log.processUserId.toString()),
                if (log.processTime != null)
                  _buildInfoRow(S.current.processTime, log.processTime),
              ]),
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
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonRow(String label, String? jsonStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              jsonStr ?? '-',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackTraceRow(String? stackTrace) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.exceptionStackTrace,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Text(
                stackTrace ?? '-',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(int? userType) {
    switch (userType) {
      case 1:
        return 'Admin';
      case 2:
        return 'Member';
      default:
        return '-';
    }
  }

  String _getProcessStatusText(int? processStatus) {
    switch (processStatus) {
      case 0:
        return S.current.processStatusInit;
      case 1:
        return S.current.processStatusDone;
      case 2:
        return S.current.processStatusIgnore;
      default:
        return '-';
    }
  }
}