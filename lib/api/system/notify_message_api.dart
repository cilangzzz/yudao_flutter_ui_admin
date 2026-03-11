import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/notify_message.dart';

/// 站内信消息管理 API
class NotifyMessageApi {
  final ApiClient _client;

  NotifyMessageApi(this._client);

  /// 查询站内信消息列表
  Future<ApiResponse<PageResult<NotifyMessage>>> getNotifyMessagePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<NotifyMessage>>(
      '/system/notify-message/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => NotifyMessage.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 获得我的站内信分页
  Future<ApiResponse<PageResult<NotifyMessage>>> getMyNotifyMessagePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<NotifyMessage>>(
      '/system/notify-message/my-page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => NotifyMessage.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 批量标记已读
  Future<ApiResponse<void>> updateNotifyMessageRead(List<int> ids) async {
    return _client.put<void>(
      '/system/notify-message/update-read',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 标记所有站内信为已读
  Future<ApiResponse<void>> updateAllNotifyMessageRead() async {
    return _client.put<void>(
      '/system/notify-message/update-all-read',
    );
  }

  /// 获取当前用户的最新站内信列表（未读）
  Future<ApiResponse<List<NotifyMessage>>> getUnreadNotifyMessageList() async {
    return _client.get<List<NotifyMessage>>(
      '/system/notify-message/get-unread-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => NotifyMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获得当前用户的未读站内信数量
  Future<ApiResponse<int>> getUnreadNotifyMessageCount() async {
    return _client.get<int>(
      '/system/notify-message/get-unread-count',
      fromJsonT: (json) => json as int,
    );
  }
}

/// NotifyMessageApi 提供者
final notifyMessageApiProvider = Provider<NotifyMessageApi>((ref) {
  return NotifyMessageApi(ref.watch(apiClientProvider));
});