import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/infra_config_api.dart';
import '../../../core/constants/app_constants.dart';
import '../../../i18n/i18n.dart';
import '../common/widgets/iframe_placeholder.dart';

/// Druid 监控页面
class DruidPage extends ConsumerWidget {
  const DruidPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IframePlaceholderPage(
      title: S.current.druidMonitor,
      configKey: 'url.druid',
      defaultUrl: '${AppConstants.baseUrl}/druid/index.html',
      description: S.current.druidMonitorDesc,
      docUrl: 'https://doc.iocoder.cn/mybatis/',
      loadUrl: () async {
        try {
          final api = ref.read(infraConfigApiProvider);
          final response = await api.getConfigKey('url.druid');
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