import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/infra_config_api.dart';
import '../../../core/constants/app_constants.dart';
import '../../../i18n/i18n.dart';
import '../common/widgets/iframe_placeholder.dart';

/// 服务器监控页面
class ServerPage extends ConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IframePlaceholderPage(
      title: S.current.serverMonitor,
      configKey: 'url.spring-boot-admin',
      defaultUrl: '${AppConstants.baseUrl}/admin/applications',
      description: S.current.serverMonitorDesc,
      docUrl: 'https://doc.iocoder.cn/server-monitor/',
      loadUrl: () async {
        try {
          final api = ref.read(infraConfigApiProvider);
          final response = await api.getConfigKey('url.spring-boot-admin');
          if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
            return response.data;
          }
        } catch (e) {
          // 使用默认 URL
        }
        return null;
      },
    );
  }
}