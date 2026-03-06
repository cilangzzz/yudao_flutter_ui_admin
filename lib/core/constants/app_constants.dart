/// 应用常量配置
class AppConstants {
  AppConstants._();

  /// API 基础地址
  static const String baseUrl = 'https://api.example.com';

  /// 租户ID
  static const String tenantId = '1';

  /// Token 存储键
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  /// 用户信息存储键
  static const String userInfoKey = 'user_info';

  /// 默认超时时间（毫秒）
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  /// 分页默认配置
  static const int defaultPageSize = 10;
  static const int defaultPageNum = 1;
}