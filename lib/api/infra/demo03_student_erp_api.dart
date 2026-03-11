import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';

/// 学生 API - Demo03 ERP模式 (主子表)
class Demo03StudentErpApi {
  final ApiClient _client;

  Demo03StudentErpApi(this._client);

  /// 分页查询学生
  Future<ApiResponse<PageResult<Demo03Student>>> getDemo03StudentPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo03Student>>(
      '/infra/demo03-student-erp/page',
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
      '/infra/demo03-student-erp/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo03Student.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增学生
  Future<ApiResponse<void>> createDemo03Student(Demo03Student data) async {
    return _client.post<void>(
      '/infra/demo03-student-erp/create',
      data: data.toJson(),
    );
  }

  /// 修改学生
  Future<ApiResponse<void>> updateDemo03Student(Demo03Student data) async {
    return _client.put<void>(
      '/infra/demo03-student-erp/update',
      data: data.toJson(),
    );
  }

  /// 删除学生
  Future<ApiResponse<void>> deleteDemo03Student(int id) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除学生
  Future<ApiResponse<void>> deleteDemo03StudentList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 导出学生
  Future<ApiResponse<dynamic>> exportDemo03Student(Map<String, dynamic> params) async {
    return _client.get<dynamic>(
      '/infra/demo03-student-erp/export-excel',
      queryParameters: params,
    );
  }

  // ============ 子表API（课程） ============

  /// 获得学生课程分页
  Future<ApiResponse<PageResult<Demo03Course>>> getDemo03CoursePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo03Course>>(
      '/infra/demo03-student-erp/demo03-course/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Demo03Course.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 获得学生课程
  Future<ApiResponse<Demo03Course>> getDemo03Course(int id) async {
    return _client.get<Demo03Course>(
      '/infra/demo03-student-erp/demo03-course/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo03Course.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增学生课程
  Future<ApiResponse<void>> createDemo03Course(Demo03Course data) async {
    return _client.post<void>(
      '/infra/demo03-student-erp/demo03-course/create',
      data: data.toJson(),
    );
  }

  /// 修改学生课程
  Future<ApiResponse<void>> updateDemo03Course(Demo03Course data) async {
    return _client.put<void>(
      '/infra/demo03-student-erp/demo03-course/update',
      data: data.toJson(),
    );
  }

  /// 删除学生课程
  Future<ApiResponse<void>> deleteDemo03Course(int id) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/demo03-course/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除学生课程
  Future<ApiResponse<void>> deleteDemo03CourseList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/demo03-course/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  // ============ 子表API（班级） ============

  /// 获得学生班级分页
  Future<ApiResponse<PageResult<Demo03Grade>>> getDemo03GradePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo03Grade>>(
      '/infra/demo03-student-erp/demo03-grade/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Demo03Grade.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 获得学生班级
  Future<ApiResponse<Demo03Grade>> getDemo03Grade(int id) async {
    return _client.get<Demo03Grade>(
      '/infra/demo03-student-erp/demo03-grade/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo03Grade.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增学生班级
  Future<ApiResponse<void>> createDemo03Grade(Demo03Grade data) async {
    return _client.post<void>(
      '/infra/demo03-student-erp/demo03-grade/create',
      data: data.toJson(),
    );
  }

  /// 修改学生班级
  Future<ApiResponse<void>> updateDemo03Grade(Demo03Grade data) async {
    return _client.put<void>(
      '/infra/demo03-student-erp/demo03-grade/update',
      data: data.toJson(),
    );
  }

  /// 删除学生班级
  Future<ApiResponse<void>> deleteDemo03Grade(int id) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/demo03-grade/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除学生班级
  Future<ApiResponse<void>> deleteDemo03GradeList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo03-student-erp/demo03-grade/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// Demo03StudentErpApi 提供者
final demo03StudentErpApiProvider = Provider<Demo03StudentErpApi>((ref) {
  return Demo03StudentErpApi(ref.watch(apiClientProvider));
});