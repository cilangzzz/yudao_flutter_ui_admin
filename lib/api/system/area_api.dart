import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/system/area.dart';

/// 地区管理 API
class AreaApi {
  final ApiClient _client;

  AreaApi(this._client);

  /// 获得地区树
  Future<ApiResponse<List<Area>>> getAreaTree() async {
    return _client.get<List<Area>>(
      '/system/area/tree',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Area.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获得 IP 对应的地区名
  Future<ApiResponse<String>> getAreaByIp(String ip) async {
    return _client.get<String>(
      '/system/area/get-by-ip',
      queryParameters: {'ip': ip},
      fromJsonT: (json) => json as String,
    );
  }
}

/// AreaApi 提供者
final areaApiProvider = Provider<AreaApi>((ref) {
  return AreaApi(ref.watch(apiClientProvider));
});