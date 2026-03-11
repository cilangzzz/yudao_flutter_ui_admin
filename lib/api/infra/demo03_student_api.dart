import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';

/// 学生 API - Demo03 (主子表)
class Demo03StudentApi {
  final ApiClient _client;

  Demo03StudentApi(this._client);

  /// 分页查询学生
  Future<ApiResponse<PageResult<Demo03Student>>> getDemo03StudentPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo03Student>>(
      '/infra/demo03-student/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Demo03Student.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询学生详情
  Future<ApiResponse<Demo03Student>> getDemo03Student(int id) async {
    return _client.get<Demo03Student>(
      '/infra/demo03-student/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo03Student.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增学生
  Future<ApiResponse<void>> createDemo03Student(Demo03Student data) async {
    return _client.post<void>(
      '/infra/demo03-student/create',
      data: data.toJson(),
    );
  }

  /// 修改学生
  Future<ApiResponse<void>> updateDemo03Student(Demo03Student data) async {
    return _client.put<void>(
      '/infra/demo03-student/update',
      data: data.toJson(),
    );
  }

  /// 删除学生
  Future<ApiResponse<void>> deleteDemo03Student(int id) async {
    return _client.delete<void>(
      '/infra/demo03-student/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除学生
  Future<ApiResponse<void>> deleteDemo03StudentList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo03-student/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 导出学生
  Future<ApiResponse<dynamic>> exportDemo03Student(Map<String, dynamic> params) async {
    return _client.get<dynamic>(
      '/infra/demo03-student/export-excel',
      queryParameters: params,
    );
  }
}

/// Demo03StudentApi 提供者
final demo03StudentApiProvider = Provider<Demo03StudentApi>((ref) {
  return Demo03StudentApi(ref.watch(apiClientProvider));
});