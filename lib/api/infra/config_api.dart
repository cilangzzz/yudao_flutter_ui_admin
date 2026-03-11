import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/infra/config.dart';

/// 参数配置管理 API
class ConfigApi {
  final ApiClient _client;

  ConfigApi(this._client);

  /// 分页查询参数配置
  Future<ApiResponse<PageResult<Config>>> getConfigPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Config>>(
      '/infra/config/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Config.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询参数配置详情
  Future<ApiResponse<Config>> getConfig(int id) async {
    return _client.get<Config>(
      '/infra/config/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Config.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 根据参数键名查询参数值
  Future<ApiResponse<String>> getConfigKey(String configKey) async {
    return _client.get<String>(
      '/infra/config/get-value-by-key',
      queryParameters: {'key': configKey},
      fromJsonT: (json) => json?.toString() ?? '',
    );
  }

  /// 新增参数配置
  Future<ApiResponse<void>> createConfig(Config data) async {
    return _client.post<void>(
      '/infra/config/create',
      data: data.toJson(),
    );
  }

  /// 修改参数配置
  Future<ApiResponse<void>> updateConfig(Config data) async {
    return _client.put<void>(
      '/infra/config/update',
      data: data.toJson(),
    );
  }

  /// 删除参数配置
  Future<ApiResponse<void>> deleteConfig(int id) async {
    return _client.delete<void>(
      '/infra/config/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除参数配置
  Future<ApiResponse<void>> deleteConfigList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/config/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// ConfigApi 提供者
final configApiProvider = Provider<ConfigApi>((ref) {
  return ConfigApi(ref.watch(apiClientProvider));
});