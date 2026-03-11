import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/infra/job_log.dart';

/// 任务执行日志 API
class JobLogApi {
  final ApiClient _client;

  JobLogApi(this._client);

  /// 分页查询任务日志
  Future<ApiResponse<PageResult<JobLog>>> getJobLogPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<JobLog>>(
      '/infra/job-log/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => JobLog.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询任务日志详情
  Future<ApiResponse<JobLog>> getJobLog(int id) async {
    return _client.get<JobLog>(
      '/infra/job-log/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => JobLog.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// JobLogApi 提供者
final jobLogApiProvider = Provider<JobLogApi>((ref) {
  return JobLogApi(ref.watch(apiClientProvider));
});