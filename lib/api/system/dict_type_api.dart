import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_param.dart';
import '../../models/common/page_result.dart';
import '../../models/system/dict_type.dart';

/// 字典类型管理 API
class DictTypeApi {
  final ApiClient _client;

  DictTypeApi(this._client);

  /// 分页查询字典类型
  /// [params] 分页参数
  /// [name] 字典名称（模糊搜索）
  /// [type] 字典类型（模糊搜索）
  /// [status] 状态
  Future<ApiResponse<PageResult<DictType>>> getDictTypePage(
    PageParam params, {
    String? name,
    String? type,
    int? status,
  }) async {
    final queryParams = params.toJson();
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;

    return _client.get<PageResult<DictType>>(
      '/system/dict-type/page',
      queryParameters: queryParams,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => DictType.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询字典类型详情
  Future<ApiResponse<DictType>> getDictType(int id) async {
    return _client.get<DictType>(
      '/system/dict-type/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => DictType.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增字典类型
  Future<ApiResponse<void>> createDictType(DictType data) async {
    return _client.post<void>(
      '/system/dict-type/create',
      data: data.toJson(),
    );
  }

  /// 修改字典类型
  Future<ApiResponse<void>> updateDictType(DictType data) async {
    return _client.put<void>(
      '/system/dict-type/update',
      data: data.toJson(),
    );
  }

  /// 删除字典类型
  Future<ApiResponse<void>> deleteDictType(int id) async {
    return _client.delete<void>(
      '/system/dict-type/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除字典类型
  Future<ApiResponse<void>> deleteDictTypeList(List<int> ids) async {
    return _client.delete<void>(
      '/system/dict-type/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简字典类型列表
  Future<ApiResponse<List<SimpleDictType>>> getSimpleDictTypeList() async {
    return _client.get<List<SimpleDictType>>(
      '/system/dict-type/list-all-simple',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SimpleDictType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// DictTypeApi 提供者
final dictTypeApiProvider = Provider<DictTypeApi>((ref) {
  return DictTypeApi(ref.watch(apiClientProvider));
});