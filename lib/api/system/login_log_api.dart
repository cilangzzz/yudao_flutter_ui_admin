import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/login_log.dart';

/// 登录日志 API
class LoginLogApi {
  final ApiClient _client;

  LoginLogApi(this._client);

  /// 分页查询登录日志
  Future<ApiResponse<PageResult<LoginLog>>> getLoginLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<LoginLog>>(
      '/system/login-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => LoginLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

/// LoginLogApi 提供者
final loginLogApiProvider = Provider<LoginLogApi>((ref) {
  return LoginLogApi(ref.watch(apiClientProvider));
});