import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/mail_log.dart';

/// 邮件日志 API
class MailLogApi {
  final ApiClient _client;

  MailLogApi(this._client);

  /// 分页查询邮件日志
  Future<ApiResponse<PageResult<MailLog>>> getMailLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<MailLog>>(
      '/system/mail-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => MailLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

/// MailLogApi 提供者
final mailLogApiProvider = Provider<MailLogApi>((ref) {
  return MailLogApi(ref.watch(apiClientProvider));
});