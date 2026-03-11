import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/sms_template.dart';

/// 短信模板管理 API
class SmsTemplateApi {
  final ApiClient _client;

  SmsTemplateApi(this._client);

  /// 分页查询短信模板
  Future<ApiResponse<PageResult<SmsTemplate>>> getSmsTemplatePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<SmsTemplate>>(
      '/system/sms-template/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => SmsTemplate.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询短信模板详情
  Future<ApiResponse<SmsTemplate>> getSmsTemplate(int id) async {
    return _client.get<SmsTemplate>(
      '/system/sms-template/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => SmsTemplate.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增短信模板
  Future<ApiResponse<void>> createSmsTemplate(SmsTemplate data) async {
    return _client.post<void>(
      '/system/sms-template/create',
      data: data.toJson(),
    );
  }

  /// 修改短信模板
  Future<ApiResponse<void>> updateSmsTemplate(SmsTemplate data) async {
    return _client.put<void>(
      '/system/sms-template/update',
      data: data.toJson(),
    );
  }

  /// 删除短信模板
  Future<ApiResponse<void>> deleteSmsTemplate(int id) async {
    return _client.delete<void>(
      '/system/sms-template/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除短信模板
  Future<ApiResponse<void>> deleteSmsTemplateList(List<int> ids) async {
    return _client.delete<void>(
      '/system/sms-template/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 发送短信
  Future<ApiResponse<void>> sendSms(SmsSendReqVO data) async {
    return _client.post<void>(
      '/system/sms-template/send-sms',
      data: data.toJson(),
    );
  }
}

/// SmsTemplateApi 提供者
final smsTemplateApiProvider = Provider<SmsTemplateApi>((ref) {
  return SmsTemplateApi(ref.watch(apiClientProvider));
});