import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/mail_account.dart';

/// 邮箱账号管理 API
class MailAccountApi {
  final ApiClient _client;

  MailAccountApi(this._client);

  /// 分页查询邮箱账号
  Future<ApiResponse<PageResult<MailAccount>>> getMailAccountPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<MailAccount>>(
      '/system/mail-account/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => MailAccount.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询邮箱账号详情
  Future<ApiResponse<MailAccount>> getMailAccount(int id) async {
    return _client.get<MailAccount>(
      '/system/mail-account/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => MailAccount.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增邮箱账号
  Future<ApiResponse<void>> createMailAccount(MailAccount data) async {
    return _client.post<void>(
      '/system/mail-account/create',
      data: data.toJson(),
    );
  }

  /// 修改邮箱账号
  Future<ApiResponse<void>> updateMailAccount(MailAccount data) async {
    return _client.put<void>(
      '/system/mail-account/update',
      data: data.toJson(),
    );
  }

  /// 删除邮箱账号
  Future<ApiResponse<void>> deleteMailAccount(int id) async {
    return _client.delete<void>(
      '/system/mail-account/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除邮箱账号
  Future<ApiResponse<void>> deleteMailAccountList(List<int> ids) async {
    return _client.delete<void>(
      '/system/mail-account/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简邮箱账号列表
  Future<ApiResponse<List<MailAccount>>> getSimpleMailAccountList() async {
    return _client.get<List<MailAccount>>(
      '/system/mail-account/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => MailAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// MailAccountApi 提供者
final mailAccountApiProvider = Provider<MailAccountApi>((ref) {
  return MailAccountApi(ref.watch(apiClientProvider));
});