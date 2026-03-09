import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/mail_template.dart';

/// 邮件模版管理 API
class MailTemplateApi {
  final ApiClient _client;

  MailTemplateApi(this._client);

  /// 分页查询邮件模版
  Future<ApiResponse<PageResult<MailTemplate>>> getMailTemplatePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<MailTemplate>>(
      '/system/mail-template/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => MailTemplate.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询邮件模版详情
  Future<ApiResponse<MailTemplate>> getMailTemplate(int id) async {
    return _client.get<MailTemplate>(
      '/system/mail-template/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => MailTemplate.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增邮件模版
  Future<ApiResponse<void>> createMailTemplate(MailTemplate data) async {
    return _client.post<void>(
      '/system/mail-template/create',
      data: data.toJson(),
    );
  }

  /// 修改邮件模版
  Future<ApiResponse<void>> updateMailTemplate(MailTemplate data) async {
    return _client.put<void>(
      '/system/mail-template/update',
      data: data.toJson(),
    );
  }

  /// 删除邮件模版
  Future<ApiResponse<void>> deleteMailTemplate(int id) async {
    return _client.delete<void>(
      '/system/mail-template/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除邮件模版
  Future<ApiResponse<void>> deleteMailTemplateList(List<int> ids) async {
    return _client.delete<void>(
      '/system/mail-template/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 发送邮件
  Future<ApiResponse<void>> sendMail(MailSendReqVO data) async {
    return _client.post<void>(
      '/system/mail-template/send-mail',
      data: data.toJson(),
    );
  }
}

/// MailTemplateApi 提供者
final mailTemplateApiProvider = Provider<MailTemplateApi>((ref) {
  return MailTemplateApi(ref.watch(apiClientProvider));
});