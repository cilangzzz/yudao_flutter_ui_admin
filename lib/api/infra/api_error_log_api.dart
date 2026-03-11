import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_error_log.dart';

/// API 错误日志管理 API
class ApiErrorLogApi {
  final ApiClient _client;

  ApiErrorLogApi(this._client);

  /// 分页查询 API 错误日志
  Future<ApiResponse<PageResult<ApiErrorLog>>> getApiErrorLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<ApiErrorLog>>(
      '/infra/api-error-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => ApiErrorLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 更新 API 错误日志的处理状态
  Future<ApiResponse<void>> updateApiErrorLogStatus(int id, int processStatus) async {
    return _client.put<void>(
      '/infra/api-error-log/update-status',
      queryParameters: {'id': id, 'processStatus': processStatus},
    );
  }

  /// 导出 API 错误日志
  Future<ApiResponse<void>> exportApiErrorLog(Map<String, dynamic> params) async {
    return _client.download(
      '/infra/api-error-log/export-excel',
      queryParameters: params,
    );
  }
}

/// ApiErrorLogApi 提供者
final apiErrorLogApiProvider = Provider<ApiErrorLogApi>((ref) {
  return ApiErrorLogApi(ref.watch(apiClientProvider));
});