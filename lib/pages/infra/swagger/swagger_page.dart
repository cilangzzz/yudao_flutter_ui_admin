import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/infra_config_api.dart';
import 'package:yudao_flutter_ui_admin/core/constants/app_constants.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/pages/infra/common/widgets/iframe_placeholder.dart';

/// API 文档页面
class SwaggerPage extends ConsumerWidget {
  const SwaggerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IframePlaceholderPage(
      title: S.current.apiDocs,
      configKey: 'url.swagger',
      defaultUrl: '${AppConstants.baseUrl}/doc.html',
      description: S.current.apiDocsDesc,
      docUrl: 'https://doc.iocoder.cn/api-doc/',
      loadUrl: () async {
        try {
          final api = ref.read(infraConfigApiProvider);
          final response = await api.getConfigKey('url.swagger');
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