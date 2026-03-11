import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/sms_log.dart';

/// 短信日志 API
class SmsLogApi {
  final ApiClient _client;

  SmsLogApi(this._client);

  /// 分页查询短信日志
  Future<ApiResponse<PageResult<SmsLog>>> getSmsLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<SmsLog>>(
      '/system/sms-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => SmsLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

/// SmsLogApi 提供者
final smsLogApiProvider = Provider<SmsLogApi>((ref) {
  return SmsLogApi(ref.watch(apiClientProvider));
});