import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/infra/redis.dart';

/// Redis 管理 API
class RedisApi {
  final ApiClient _client;

  RedisApi(this._client);

  /// 获取 Redis 监控信息
  Future<ApiResponse<RedisMonitorInfo>> getRedisMonitorInfo() async {
    return _client.get<RedisMonitorInfo>(
      '/infra/redis/get-monitor-info',
      fromJsonT: (json) => RedisMonitorInfo.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// RedisApi 提供者
final redisApiProvider = Provider<RedisApi>((ref) {
  return RedisApi(ref.watch(apiClientProvider));
});