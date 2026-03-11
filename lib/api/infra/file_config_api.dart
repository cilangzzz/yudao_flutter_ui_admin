import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file_config.dart';

/// 文件配置管理 API
class FileConfigApi {
  final ApiClient _client;

  FileConfigApi(this._client);

  /// 分页查询文件配置
  Future<ApiResponse<PageResult<FileConfig>>> getFileConfigPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<FileConfig>>(
      '/infra/file-config/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => FileConfig.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询文件配置详情
  Future<ApiResponse<FileConfig>> getFileConfig(int id) async {
    return _client.get<FileConfig>(
      '/infra/file-config/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => FileConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 更新文件配置为主配置
  Future<ApiResponse<void>> updateFileConfigMaster(int id) async {
    return _client.put<void>(
      '/infra/file-config/update-master',
      queryParameters: {'id': id},
    );
  }

  /// 新增文件配置
  Future<ApiResponse<void>> createFileConfig(FileConfig data) async {
    return _client.post<void>(
      '/infra/file-config/create',
      data: data.toJson(),
    );
  }

  /// 修改文件配置
  Future<ApiResponse<void>> updateFileConfig(FileConfig data) async {
    return _client.put<void>(
      '/infra/file-config/update',
      data: data.toJson(),
    );
  }

  /// 删除文件配置
  Future<ApiResponse<void>> deleteFileConfig(int id) async {
    return _client.delete<void>(
      '/infra/file-config/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除文件配置
  Future<ApiResponse<void>> deleteFileConfigList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/file-config/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 测试文件配置
  Future<ApiResponse<String>> testFileConfig(int id) async {
    return _client.get<String>(
      '/infra/file-config/test',
      queryParameters: {'id': id},
      fromJsonT: (json) => json?.toString() ?? '',
    );
  }
}

/// FileConfigApi 提供者
final fileConfigApiProvider = Provider<FileConfigApi>((ref) {
  return FileConfigApi(ref.watch(apiClientProvider));
});