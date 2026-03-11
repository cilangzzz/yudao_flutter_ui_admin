import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/post.dart';

/// 岗位管理 API
class PostApi {
  final ApiClient _client;

  PostApi(this._client);

  /// 分页查询岗位
  Future<ApiResponse<PageResult<Post>>> getPostPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Post>>(
      '/system/post/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Post.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 获取岗位精简信息列表
  Future<ApiResponse<List<Post>>> getSimplePostList() async {
    return _client.get<List<Post>>(
      '/system/post/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询岗位详情
  Future<ApiResponse<Post>> getPost(int id) async {
    return _client.get<Post>(
      '/system/post/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Post.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增岗位
  Future<ApiResponse<void>> createPost(Post data) async {
    return _client.post<void>(
      '/system/post/create',
      data: data.toJson(),
    );
  }

  /// 修改岗位
  Future<ApiResponse<void>> updatePost(Post data) async {
    return _client.put<void>(
      '/system/post/update',
      data: data.toJson(),
    );
  }

  /// 删除岗位
  Future<ApiResponse<void>> deletePost(int id) async {
    return _client.delete<void>(
      '/system/post/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除岗位
  Future<ApiResponse<void>> deletePostList(List<int> ids) async {
    return _client.delete<void>(
      '/system/post/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// PostApi 提供者
final postApiProvider = Provider<PostApi>((ref) {
  return PostApi(ref.watch(apiClientProvider));
});