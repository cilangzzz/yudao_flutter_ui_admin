import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/user.dart';

/// 用户管理 API
class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  /// 分页查询用户
  Future<ApiResponse<PageResult<User>>> getUserPage(UserPageParam params) async {
    return _client.get<PageResult<User>>(
      '/system/user/page',
      queryParameters: params.toJson(),
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => User.fromJson(e as Map<String,dynamic>),
      ),
    );
  }

  /// 查询用户详情
  Future<ApiResponse<User>> getUser(int id) async {
    return _client.get<User>(
      '/system/user/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增用户
  Future<ApiResponse<void>> createUser(User data) async {
    return _client.post<void>(
      '/system/user/create',
      data: data.toJson(),
    );
  }

  /// 修改用户
  Future<ApiResponse<void>> updateUser(User data) async {
    return _client.put<void>(
      '/system/user/update',
      data: data.toJson(),
    );
  }

  /// 删除用户
  Future<ApiResponse<void>> deleteUser(int id) async {
    return _client.delete<void>(
      '/system/user/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除用户
  Future<ApiResponse<void>> deleteUserList(List<int> ids) async {
    return _client.delete<void>(
      '/system/user/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 重置用户密码
  Future<ApiResponse<void>> resetUserPassword(int id, String password) async {
    return _client.put<void>(
      '/system/user/update-password',
      data: {'id': id, 'password': password},
    );
  }

  /// 修改用户状态
  Future<ApiResponse<void>> updateUserStatus(int id, int status) async {
    return _client.put<void>(
      '/system/user/update-status',
      data: {'id': id, 'status': status},
    );
  }

  /// 获取精简用户列表
  Future<ApiResponse<List<SimpleUser>>> getSimpleUserList() async {
    return _client.get<List<SimpleUser>>(
      '/system/user/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SimpleUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// UserApi 提供者
final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.watch(apiClientProvider));
});