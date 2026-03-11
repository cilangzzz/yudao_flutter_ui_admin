import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file.dart';

/// 文件管理 API
class FileApi {
  final ApiClient _client;

  FileApi(this._client);

  /// 分页查询文件
  Future<ApiResponse<PageResult<File>>> getFilePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<File>>(
      '/infra/file/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => File.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 删除文件
  Future<ApiResponse<void>> deleteFile(int id) async {
    return _client.delete<void>(
      '/infra/file/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除文件
  Future<ApiResponse<void>> deleteFileList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/file/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取文件预签名地址
  Future<ApiResponse<FilePresignedUrl>> getFilePresignedUrl(String name, {String? directory}) async {
    return _client.get<FilePresignedUrl>(
      '/infra/file/presigned-url',
      queryParameters: {
        'name': name,
        if (directory != null && directory.isNotEmpty) 'directory': directory,
      },
      fromJsonT: (json) => FilePresignedUrl.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 创建文件
  Future<ApiResponse<void>> createFile(File data) async {
    return _client.post<void>(
      '/infra/file/create',
      data: data.toJson(),
    );
  }
}

/// 文件预签名地址
class FilePresignedUrl {
  final int configId;
  final String uploadUrl;
  final String url;
  final String path;

  FilePresignedUrl({
    required this.configId,
    required this.uploadUrl,
    required this.url,
    required this.path,
  });

  factory FilePresignedUrl.fromJson(Map<String, dynamic> json) {
    return FilePresignedUrl(
      configId: json['configId'] is int ? json['configId'] : int.tryParse(json['configId']?.toString() ?? '') ?? 0,
      uploadUrl: json['uploadUrl']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
    );
  }
}

/// FileApi 提供者
final fileApiProvider = Provider<FileApi>((ref) {
  return FileApi(ref.watch(apiClientProvider));
});