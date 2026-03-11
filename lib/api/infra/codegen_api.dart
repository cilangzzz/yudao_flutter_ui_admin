import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/codegen.dart';

/// 代码生成 API
class CodegenApi {
  final ApiClient _client;

  CodegenApi(this._client);

  /// 分页查询代码生成表定义
  Future<ApiResponse<PageResult<CodegenTable>>> getCodegenTablePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<CodegenTable>>(
      '/infra/codegen/table/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => CodegenTable.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询列表代码生成表定义
  Future<ApiResponse<List<CodegenTable>>> getCodegenTableList(int dataSourceConfigId) async {
    return _client.get<List<CodegenTable>>(
      '/infra/codegen/table/list',
      queryParameters: {'dataSourceConfigId': dataSourceConfigId},
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => CodegenTable.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询详情代码生成表定义
  Future<ApiResponse<CodegenDetail>> getCodegenTable(int tableId) async {
    return _client.get<CodegenDetail>(
      '/infra/codegen/detail',
      queryParameters: {'tableId': tableId},
      fromJsonT: (json) => CodegenDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 修改代码生成表定义
  Future<ApiResponse<void>> updateCodegenTable(CodegenUpdateReq data) async {
    return _client.put<void>(
      '/infra/codegen/update',
      data: data.toJson(),
    );
  }

  /// 基于数据库的表结构，同步数据库的表和字段定义
  Future<ApiResponse<void>> syncCodegenFromDB(int tableId) async {
    return _client.put<void>(
      '/infra/codegen/sync-from-db',
      queryParameters: {'tableId': tableId},
    );
  }

  /// 预览生成代码
  Future<ApiResponse<List<CodegenPreview>>> previewCodegen(int tableId) async {
    return _client.get<List<CodegenPreview>>(
      '/infra/codegen/preview',
      queryParameters: {'tableId': tableId},
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => CodegenPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 下载生成代码
  Future<ApiResponse<String>> downloadCodegen(int tableId) async {
    return _client.get<String>(
      '/infra/codegen/download',
      queryParameters: {'tableId': tableId},
    );
  }

  /// 获得表定义
  Future<ApiResponse<List<DatabaseTable>>> getSchemaTableList(Map<String, dynamic> params) async {
    return _client.get<List<DatabaseTable>>(
      '/infra/codegen/db/table/list',
      queryParameters: params,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => DatabaseTable.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 基于数据库的表结构，创建代码生成器的表定义
  Future<ApiResponse<void>> createCodegenList(CodegenCreateReq data) async {
    return _client.post<void>(
      '/infra/codegen/create-list',
      data: data.toJson(),
    );
  }

  /// 删除代码生成表定义
  Future<ApiResponse<void>> deleteCodegenTable(int tableId) async {
    return _client.delete<void>(
      '/infra/codegen/delete',
      queryParameters: {'tableId': tableId},
    );
  }

  /// 批量删除代码生成表定义
  Future<ApiResponse<void>> deleteCodegenTableList(List<int> tableIds) async {
    return _client.delete<void>(
      '/infra/codegen/delete-list',
      queryParameters: {'tableIds': tableIds.join(',')},
    );
  }
}

/// CodegenApi 提供者
final codegenApiProvider = Provider<CodegenApi>((ref) {
  return CodegenApi(ref.watch(apiClientProvider));
});

/// 数据源配置 API
class DataSourceConfigApi {
  final ApiClient _client;

  DataSourceConfigApi(this._client);

  /// 获取数据源配置列表
  Future<ApiResponse<List<DataSourceConfig>>> getDataSourceConfigList() async {
    return _client.get<List<DataSourceConfig>>(
      '/infra/data-source-config/list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => DataSourceConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// DataSourceConfigApi 提供者
final dataSourceConfigApiProvider = Provider<DataSourceConfigApi>((ref) {
  return DataSourceConfigApi(ref.watch(apiClientProvider));
});