import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_access_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 显示 API 访问日志详情弹窗
Future<void> showApiAccessLogDetailDialog(
  BuildContext context, {
  required ApiAccessLog log,
}) async {
  final isMobile = DeviceUIMode.isMobile(context);

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ApiAccessLogDetailBottomSheet(log: log),
    );
  } else {
    await showDialog(
      context: context,
      builder: (context) => ApiAccessLogDetailDialog(log: log),
    );
  }
}

/// API 访问日志详情弹窗组件
class ApiAccessLogDetailDialog extends StatelessWidget {
  final ApiAccessLog log;

  const ApiAccessLogDetailDialog({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.apiAccessLogDetail),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow(S.current.logId, log.id?.toString()),
              _buildInfoRow(S.current.traceId, log.traceId),
              _buildInfoRow(S.current.applicationName, log.applicationName),
              _buildInfoRow(S.current.userId, log.userId?.toString()),
              _buildInfoRow(S.current.userType, _getUserTypeText(log.userType)),
              _buildInfoRow(S.current.userIp, log.userIp),
              _buildInfoRow(S.current.userAgent, log.userAgent),
              _buildInfoRow(
                S.current.requestInfo,
                '${log.requestMethod} ${log.requestUrl}',
              ),
              _buildJsonRow(S.current.requestParams, log.requestParams),
              _buildInfoRow(S.current.responseBody, log.responseBody, maxLines: 5),
              _buildInfoRow(
                S.current.requestTime,
                '${log.beginTime} ~ ${log.endTime}',
              ),
              _buildInfoRow(S.current.duration, '${log.duration} ms'),
              _buildInfoRow(
                S.current.resultCode,
                log.resultCode == 0
                    ? S.current.success
                    : '${S.current.failed} | ${log.resultCode} | ${log.resultMsg}',
              ),
              _buildInfoRow(S.current.operateModule, log.operateModule),
              _buildInfoRow(S.current.operateName, log.operateName),
              _buildInfoRow(S.current.operateType, _getOperateTypeText(log.operateType)),
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

  Widget _buildInfoRow(String label, String? value, {int maxLines = 1}) {
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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

  String _getOperateTypeText(int? operateType) {
    switch (operateType) {
      case 1:
        return S.current.operateTypeOther;
      case 2:
        return S.current.operateTypeCreate;
      case 3:
        return S.current.operateTypeUpdate;
      case 4:
        return S.current.operateTypeDelete;
      default:
        return '-';
    }
  }
}

/// API 访问日志详情底部弹出组件 (移动端)
class _ApiAccessLogDetailBottomSheet extends StatelessWidget {
  final ApiAccessLog log;

  const _ApiAccessLogDetailBottomSheet({required this.log});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
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
                    S.current.apiAccessLogDetail,
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
                    _buildMobileInfoRow(S.current.logId, log.id?.toString()),
                    _buildMobileInfoRow(S.current.traceId, log.traceId),
                    _buildMobileInfoRow(S.current.applicationName, log.applicationName),
                    _buildMobileInfoRow(S.current.userId, log.userId?.toString()),
                    _buildMobileInfoRow(S.current.userType, _getUserTypeText(log.userType)),
                    _buildMobileInfoRow(S.current.userIp, log.userIp),
                    _buildMobileInfoRow(S.current.userAgent, log.userAgent),
                    _buildMobileInfoRow(
                      S.current.requestInfo,
                      '${log.requestMethod} ${log.requestUrl}',
                    ),
                    _buildMobileJsonRow(S.current.requestParams, log.requestParams),
                    _buildMobileInfoRow(S.current.responseBody, log.responseBody, maxLines: 5),
                    _buildMobileInfoRow(
                      S.current.requestTime,
                      '${log.beginTime} ~ ${log.endTime}',
                    ),
                    _buildMobileInfoRow(S.current.duration, '${log.duration} ms'),
                    _buildMobileInfoRow(
                      S.current.resultCode,
                      log.resultCode == 0
                          ? S.current.success
                          : '${S.current.failed} | ${log.resultCode} | ${log.resultMsg}',
                    ),
                    _buildMobileInfoRow(S.current.operateModule, log.operateModule),
                    _buildMobileInfoRow(S.current.operateName, log.operateName),
                    _buildMobileInfoRow(S.current.operateType, _getOperateTypeText(log.operateType)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String? value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileJsonRow(String label, String? jsonStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
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
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
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

  String _getOperateTypeText(int? operateType) {
    switch (operateType) {
      case 1:
        return S.current.operateTypeOther;
      case 2:
        return S.current.operateTypeCreate;
      case 3:
        return S.current.operateTypeUpdate;
      case 4:
        return S.current.operateTypeDelete;
      default:
        return '-';
    }
  }
}