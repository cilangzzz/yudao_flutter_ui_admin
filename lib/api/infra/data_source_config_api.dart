import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/infra/data_source_config.dart';

/// 数据源配置管理 API
class DataSourceConfigApi {
  final ApiClient _client;

  DataSourceConfigApi(this._client);

  /// 查询数据源配置列表
  Future<ApiResponse<List<DataSourceConfig>>> getDataSourceConfigList() async {
    return _client.get<List<DataSourceConfig>>(
      '/infra/data-source-config/list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => DataSourceConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询数据源配置详情
  Future<ApiResponse<DataSourceConfig>> getDataSourceConfig(int id) async {
    return _client.get<DataSourceConfig>(
      '/infra/data-source-config/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => DataSourceConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增数据源配置
  Future<ApiResponse<void>> createDataSourceConfig(DataSourceConfig data) async {
    return _client.post<void>(
      '/infra/data-source-config/create',
      data: data.toJson(),
    );
  }

  /// 修改数据源配置
  Future<ApiResponse<void>> updateDataSourceConfig(DataSourceConfig data) async {
    return _client.put<void>(
      '/infra/data-source-config/update',
      data: data.toJson(),
    );
  }

  /// 删除数据源配置
  Future<ApiResponse<void>> deleteDataSourceConfig(int id) async {
    return _client.delete<void>(
      '/infra/data-source-config/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除数据源配置
  Future<ApiResponse<void>> deleteDataSourceConfigList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/data-source-config/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// DataSourceConfigApi 提供者
final dataSourceConfigApiProvider = Provider<DataSourceConfigApi>((ref) {
  return DataSourceConfigApi(ref.watch(apiClientProvider));
});