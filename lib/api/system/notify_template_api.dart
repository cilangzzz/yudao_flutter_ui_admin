import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/notify_template.dart';

/// 站内信模板管理 API
class NotifyTemplateApi {
  final ApiClient _client;

  NotifyTemplateApi(this._client);

  /// 查询站内信模板列表
  Future<ApiResponse<PageResult<NotifyTemplate>>> getNotifyTemplatePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<NotifyTemplate>>(
      '/system/notify-template/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => NotifyTemplate.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询站内信模板详情
  Future<ApiResponse<NotifyTemplate>> getNotifyTemplate(int id) async {
    return _client.get<NotifyTemplate>(
      '/system/notify-template/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => NotifyTemplate.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增站内信模板
  Future<ApiResponse<void>> createNotifyTemplate(NotifyTemplate data) async {
    return _client.post<void>(
      '/system/notify-template/create',
      data: data.toJson(),
    );
  }

  /// 修改站内信模板
  Future<ApiResponse<void>> updateNotifyTemplate(NotifyTemplate data) async {
    return _client.put<void>(
      '/system/notify-template/update',
      data: data.toJson(),
    );
  }

  /// 删除站内信模板
  Future<ApiResponse<void>> deleteNotifyTemplate(int id) async {
    return _client.delete<void>(
      '/system/notify-template/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除站内信模板
  Future<ApiResponse<void>> deleteNotifyTemplateList(List<int> ids) async {
    return _client.delete<void>(
      '/system/notify-template/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 发送站内信
  Future<ApiResponse<void>> sendNotify(NotifySendReq data) async {
    return _client.post<void>(
      '/system/notify-template/send-notify',
      data: data.toJson(),
    );
  }
}

/// NotifyTemplateApi 提供者
final notifyTemplateApiProvider = Provider<NotifyTemplateApi>((ref) {
  return NotifyTemplateApi(ref.watch(apiClientProvider));
});