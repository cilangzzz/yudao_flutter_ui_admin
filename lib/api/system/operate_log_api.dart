import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/operate_log.dart';

/// 操作日志 API
class OperateLogApi {
  final ApiClient _client;

  OperateLogApi(this._client);

  /// 分页查询操作日志
  Future<ApiResponse<PageResult<OperateLog>>> getOperateLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<OperateLog>>(
      '/system/operate-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => OperateLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

/// OperateLogApi 提供者
final operateLogApiProvider = Provider<OperateLogApi>((ref) {
  return OperateLogApi(ref.watch(apiClientProvider));
});