import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_access_log.dart';

/// API 访问日志管理 API
class ApiAccessLogApi {
  final ApiClient _client;

  ApiAccessLogApi(this._client);

  /// 分页查询 API 访问日志
  Future<ApiResponse<PageResult<ApiAccessLog>>> getApiAccessLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<ApiAccessLog>>(
      '/infra/api-access-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => ApiAccessLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 导出 API 访问日志
  Future<ApiResponse<void>> exportApiAccessLog(Map<String, dynamic> params) async {
    return _client.download(
      '/infra/api-access-log/export-excel',
      queryParameters: params,
    );
  }
}

/// ApiAccessLogApi 提供者
final apiAccessLogApiProvider = Provider<ApiAccessLogApi>((ref) {
  return ApiAccessLogApi(ref.watch(apiClientProvider));
});