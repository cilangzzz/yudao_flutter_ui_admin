import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/notice.dart';

/// 通知公告管理 API
class NoticeApi {
  final ApiClient _client;

  NoticeApi(this._client);

  /// 分页查询公告
  Future<ApiResponse<PageResult<Notice>>> getNoticePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Notice>>(
      '/system/notice/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Notice.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询公告详情
  Future<ApiResponse<Notice>> getNotice(int id) async {
    return _client.get<Notice>(
      '/system/notice/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Notice.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增公告
  Future<ApiResponse<void>> createNotice(Notice data) async {
    return _client.post<void>(
      '/system/notice/create',
      data: data.toJson(),
    );
  }

  /// 修改公告
  Future<ApiResponse<void>> updateNotice(Notice data) async {
    return _client.put<void>(
      '/system/notice/update',
      data: data.toJson(),
    );
  }

  /// 删除公告
  Future<ApiResponse<void>> deleteNotice(int id) async {
    return _client.delete<void>(
      '/system/notice/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除公告
  Future<ApiResponse<void>> deleteNoticeList(List<int> ids) async {
    return _client.delete<void>(
      '/system/notice/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 推送公告
  Future<ApiResponse<void>> pushNotice(int id) async {
    return _client.post<void>(
      '/system/notice/push',
      queryParameters: {'id': id},
    );
  }
}

/// NoticeApi 提供者
final noticeApiProvider = Provider<NoticeApi>((ref) {
  return NoticeApi(ref.watch(apiClientProvider));
});