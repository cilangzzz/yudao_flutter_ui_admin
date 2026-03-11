import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job.dart';

/// 定时任务管理 API
class JobApi {
  final ApiClient _client;

  JobApi(this._client);

  /// 分页查询定时任务
  Future<ApiResponse<PageResult<Job>>> getJobPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Job>>(
      '/infra/job/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Job.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询定时任务详情
  Future<ApiResponse<Job>> getJob(int id) async {
    return _client.get<Job>(
      '/infra/job/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Job.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增定时任务
  Future<ApiResponse<void>> createJob(Job data) async {
    return _client.post<void>(
      '/infra/job/create',
      data: data.toJson(),
    );
  }

  /// 修改定时任务
  Future<ApiResponse<void>> updateJob(Job data) async {
    return _client.put<void>(
      '/infra/job/update',
      data: data.toJson(),
    );
  }

  /// 删除定时任务
  Future<ApiResponse<void>> deleteJob(int id) async {
    return _client.delete<void>(
      '/infra/job/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除定时任务
  Future<ApiResponse<void>> deleteJobList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/job/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 更新任务状态
  Future<ApiResponse<void>> updateJobStatus(int id, int status) async {
    return _client.put<void>(
      '/infra/job/update-status',
      queryParameters: {'id': id, 'status': status},
    );
  }

  /// 立即执行一次任务
  Future<ApiResponse<void>> triggerJob(int id) async {
    return _client.put<void>(
      '/infra/job/trigger',
      queryParameters: {'id': id},
    );
  }

  /// 获取定时任务的下 n 次执行时间
  Future<ApiResponse<List<String>>> getJobNextTimes(int id) async {
    return _client.get<List<String>>(
      '/infra/job/get_next_times',
      queryParameters: {'id': id},
      fromJsonT: (json) => (json as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}

/// JobApi 提供者
final jobApiProvider = Provider<JobApi>((ref) {
  return JobApi(ref.watch(apiClientProvider));
});