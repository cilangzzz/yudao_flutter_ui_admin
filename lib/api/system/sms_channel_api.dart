import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/sms_channel.dart';

/// 短信渠道管理 API
class SmsChannelApi {
  final ApiClient _client;

  SmsChannelApi(this._client);

  /// 分页查询短信渠道
  Future<ApiResponse<PageResult<SmsChannel>>> getSmsChannelPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<SmsChannel>>(
      '/system/sms-channel/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => SmsChannel.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 获取精简短信渠道列表
  Future<ApiResponse<List<SmsChannel>>> getSimpleSmsChannelList() async {
    return _client.get<List<SmsChannel>>(
      '/system/sms-channel/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SmsChannel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询短信渠道详情
  Future<ApiResponse<SmsChannel>> getSmsChannel(int id) async {
    return _client.get<SmsChannel>(
      '/system/sms-channel/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => SmsChannel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增短信渠道
  Future<ApiResponse<void>> createSmsChannel(SmsChannel data) async {
    return _client.post<void>(
      '/system/sms-channel/create',
      data: data.toJson(),
    );
  }

  /// 修改短信渠道
  Future<ApiResponse<void>> updateSmsChannel(SmsChannel data) async {
    return _client.put<void>(
      '/system/sms-channel/update',
      data: data.toJson(),
    );
  }

  /// 删除短信渠道
  Future<ApiResponse<void>> deleteSmsChannel(int id) async {
    return _client.delete<void>(
      '/system/sms-channel/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除短信渠道
  Future<ApiResponse<void>> deleteSmsChannelList(List<int> ids) async {
    return _client.delete<void>(
      '/system/sms-channel/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// SmsChannelApi 提供者
final smsChannelApiProvider = Provider<SmsChannelApi>((ref) {
  return SmsChannelApi(ref.watch(apiClientProvider));
});