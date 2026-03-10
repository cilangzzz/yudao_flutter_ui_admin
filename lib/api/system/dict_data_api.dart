import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_param.dart';
import '../../models/common/page_result.dart';
import '../../models/system/dict_data.dart';

/// 字典数据管理 API
class DictDataApi {
  final ApiClient _client;

  DictDataApi(this._client);

  /// 分页查询字典数据
  Future<ApiResponse<PageResult<DictData>>> getDictDataPage(
    PageParam params, {
    String? dictType,
    String? label,
    int? status,
  }) async {
    final queryParams = params.toJson();
    if (dictType != null) queryParams['dictType'] = dictType;
    if (label != null) queryParams['label'] = label;
    if (status != null) queryParams['status'] = status;

    return _client.get<PageResult<DictData>>(
      '/system/dict-data/page',
      queryParameters: queryParams,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => DictData.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询字典数据详情
  Future<ApiResponse<DictData>> getDictData(int id) async {
    return _client.get<DictData>(
      '/system/dict-data/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => DictData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增字典数据
  Future<ApiResponse<void>> createDictData(DictData data) async {
    return _client.post<void>(
      '/system/dict-data/create',
      data: data.toJson(),
    );
  }

  /// 修改字典数据
  Future<ApiResponse<void>> updateDictData(DictData data) async {
    return _client.put<void>(
      '/system/dict-data/update',
      data: data.toJson(),
    );
  }

  /// 删除字典数据
  Future<ApiResponse<void>> deleteDictData(int id) async {
    return _client.delete<void>(
      '/system/dict-data/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除字典数据
  Future<ApiResponse<void>> deleteDictDataList(List<int> ids) async {
    return _client.delete<void>(
      '/system/dict-data/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简字典数据列表
  Future<ApiResponse<List<DictData>>> getSimpleDictDataList() async {
    return _client.get<List<DictData>>(
      '/system/dict-data/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => DictData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 根据字典类型获取字典数据
  Future<ApiResponse<List<DictData>>> getDictDataByType(String dictType) async {
    return _client.get<List<DictData>>(
      '/system/dict-data/type',
      queryParameters: {'dictType': dictType},
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => DictData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// DictDataApi 提供者
final dictDataApiProvider = Provider<DictDataApi>((ref) {
  return DictDataApi(ref.watch(apiClientProvider));
});