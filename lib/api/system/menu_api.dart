import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';

/// 菜单管理 API
class MenuApi {
  final ApiClient _client;

  MenuApi(this._client);

  /// 查询菜单列表
  Future<ApiResponse<List<Menu>>> getMenuList({Map<String, dynamic>? params}) async {
    return _client.get<List<Menu>>(
      '/system/menu/list',
      queryParameters: params,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取菜单详情
  Future<ApiResponse<Menu>> getMenu(int id) async {
    return _client.get<Menu>(
      '/system/menu/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Menu.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增菜单
  Future<ApiResponse<void>> createMenu(Menu data) async {
    return _client.post<void>(
      '/system/menu/create',
      data: data.toJson(),
    );
  }

  /// 修改菜单
  Future<ApiResponse<void>> updateMenu(Menu data) async {
    return _client.put<void>(
      '/system/menu/update',
      data: data.toJson(),
    );
  }

  /// 删除菜单
  Future<ApiResponse<void>> deleteMenu(int id) async {
    return _client.delete<void>(
      '/system/menu/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除菜单
  Future<ApiResponse<void>> deleteMenuList(List<int> ids) async {
    return _client.delete<void>(
      '/system/menu/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简菜单列表
  Future<ApiResponse<List<SimpleMenu>>> getSimpleMenusList() async {
    return _client.get<List<SimpleMenu>>(
      '/system/menu/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SimpleMenu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// MenuApi 提供者
final menuApiProvider = Provider<MenuApi>((ref) {
  return MenuApi(ref.watch(apiClientProvider));
});