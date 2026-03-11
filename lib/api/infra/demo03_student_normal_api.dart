import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';

/// 学生 API - Demo03 Normal模式 (主子表)
class Demo03StudentNormalApi {
  final ApiClient _client;

  Demo03StudentNormalApi(this._client);

  /// 分页查询学生
  Future<ApiResponse<PageResult<Demo03Student>>> getDemo03StudentPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo03Student>>(
      '/infra/demo03-student-normal/page',
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
      '/infra/demo03-student-normal/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo03Student.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增学生
  Future<ApiResponse<void>> createDemo03Student(Demo03Student data) async {
    return _client.post<void>(
      '/infra/demo03-student-normal/create',
      data: data.toJson(),
    );
  }

  /// 修改学生
  Future<ApiResponse<void>> updateDemo03Student(Demo03Student data) async {
    return _client.put<void>(
      '/infra/demo03-student-normal/update',
      data: data.toJson(),
    );
  }

  /// 删除学生
  Future<ApiResponse<void>> deleteDemo03Student(int id) async {
    return _client.delete<void>(
      '/infra/demo03-student-normal/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除学生
  Future<ApiResponse<void>> deleteDemo03StudentList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo03-student-normal/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 导出学生
  Future<ApiResponse<dynamic>> exportDemo03Student(Map<String, dynamic> params) async {
    return _client.get<dynamic>(
      '/infra/demo03-student-normal/export-excel',
      queryParameters: params,
    );
  }

  // ============ 子表API（课程） ============

  /// 获得学生课程列表
  Future<ApiResponse<List<Demo03Course>>> getDemo03CourseListByStudentId(int studentId) async {
    return _client.get<List<Demo03Course>>(
      '/infra/demo03-student-normal/demo03-course/list-by-student-id',
      queryParameters: {'studentId': studentId},
      fromJsonT: (json) => (json as List)
          .map((e) => Demo03Course.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============ 子表API（班级） ============

  /// 获得学生班级
  Future<ApiResponse<Demo03Grade?>> getDemo03GradeByStudentId(int studentId) async {
    return _client.get<Demo03Grade?>(
      '/infra/demo03-student-normal/demo03-grade/get-by-student-id',
      queryParameters: {'studentId': studentId},
      fromJsonT: (json) => json != null
          ? Demo03Grade.fromJson(json as Map<String, dynamic>)
          : null,
    );
  }
}

/// Demo03StudentNormalApi 提供者
final demo03StudentNormalApiProvider = Provider<Demo03StudentNormalApi>((ref) {
  return Demo03StudentNormalApi(ref.watch(apiClientProvider));
});