import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/infra_config.dart';

/// 基础设施配置 API
class InfraConfigApi {
  final ApiClient _client;

  InfraConfigApi(this._client);

  /// 分页查询配置
  Future<ApiResponse<PageResult<InfraConfig>>> getConfigPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<InfraConfig>>(
      '/infra/config/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => InfraConfig.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询配置详情
  Future<ApiResponse<InfraConfig>> getConfig(int id) async {
    return _client.get<InfraConfig>(
      '/infra/config/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => InfraConfig.fromJson(json as Map<String, dynamic>),
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

  /// 新增配置
  Future<ApiResponse<void>> createConfig(InfraConfig data) async {
    return _client.post<void>(
      '/infra/config/create',
      data: data.toJson(),
    );
  }

  /// 修改配置
  Future<ApiResponse<void>> updateConfig(InfraConfig data) async {
    return _client.put<void>(
      '/infra/config/update',
      data: data.toJson(),
    );
  }

  /// 删除配置
  Future<ApiResponse<void>> deleteConfig(int id) async {
    return _client.delete<void>(
      '/infra/config/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除配置
  Future<ApiResponse<void>> deleteConfigList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/config/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// InfraConfigApi 提供者
final infraConfigApiProvider = Provider<InfraConfigApi>((ref) {
  return InfraConfigApi(ref.watch(apiClientProvider));
});