import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/infra_config_api.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/pages/infra/common/widgets/iframe_placeholder.dart';

/// Skywalking 监控页面
class SkywalkingPage extends ConsumerWidget {
  const SkywalkingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IframePlaceholderPage(
      title: S.current.skywalkingMonitor,
      configKey: 'url.skywalking',
      defaultUrl: 'http://skywalking.shop.iocoder.cn',
      description: S.current.skywalkingMonitorDesc,
      docUrl: 'https://doc.iocoder.cn/server-monitor/',
      loadUrl: () async {
        try {
          final api = ref.read(infraConfigApiProvider);
          final response = await api.getConfigKey('url.skywalking');
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