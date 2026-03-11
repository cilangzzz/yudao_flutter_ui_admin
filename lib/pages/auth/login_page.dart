import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yudao_flutter_ui_admin/router/router.dart';
import 'package:yudao_flutter_ui_admin/stores/stores.dart';
import 'package:yudao_flutter_ui_admin/api/core/auth_api.dart';
import 'package:yudao_flutter_ui_admin/models/core/auth_models.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO notifier, ref 异常
      // 在异步操作前获取所有需要的 notifier 引用，避免 widget disposed 后无法使用 ref
      final authApi = ref.read(authApiProvider);
      final accessStoreNotifier = ref.read(accessStoreProvider.notifier);
      final userStoreNotifier = ref.read(userStoreProvider.notifier);

      final response = await authApi.login(
        LoginParams(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (response.isSuccess && response.data != null) {
        // 保存 Token
        await accessStoreNotifier.setAccess(
          accessToken: response.data!.accessToken,
          refreshToken: response.data!.refreshToken,
        );

        // 获取用户权限信息
        final permissionResponse = await authApi.getAuthPermissionInfo();

        if (permissionResponse.isSuccess && permissionResponse.data != null) {
          final permissionInfo = permissionResponse.data!;

          // 保存用户信息到 userStore
          if (permissionInfo.user != null) {
            final user = permissionInfo.user!;
            await userStoreNotifier.setUserInfo(
              UserInfoStore(
                id: user.id ?? 0,
                username: user.username ?? '',
                nickname: user.nickname ?? '',
                avatar: user.avatar,
                email: user.email,
                mobile: user.mobile,
                deptId: user.deptId,
                roles: permissionInfo.roles?.map((r) => r ?? '').toList() ?? [],
                permissions: permissionInfo.permissions ?? [],
              ),
            );
          }

          // 保存菜单到 accessStore
          if (permissionInfo.menus != null && permissionInfo.menus!.isNotEmpty) {
            final menuItems = permissionInfo.menus!
                .map((menu) => _convertMenuInfoToMenuItem(menu))
                .toList();
            await accessStoreNotifier.setMenus(menuItems);
          }

          // 保存权限到 accessStore
          if (permissionInfo.permissions != null) {
            accessStoreNotifier.setPermissions(
              permissionInfo.permissions!.toSet(),
            );
          }
        }

        if (mounted) {
          // 使用 addPostFrameCallback 确保状态稳定后再导航
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(Routes.dashboard);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.loginFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.layoutBuilder(
        builder: (context, uiMode) {
          // 使用 DeviceUIMode 工具类进行响应式布局
          final isMobile = uiMode == UIMode.mobile;
          final isTablet = uiMode == UIMode.tablet;

          // 响应式值
          final containerWidth = ResponsiveValue<double>(
            mobile: double.infinity,
            tablet: 420.0,
            desktop: 480.0,
          ).of(context);

          final padding = ResponsiveValue<double>(
            mobile: 20.0,
            tablet: 28.0,
            desktop: 32.0,
          ).of(context);

          final iconSize = ResponsiveValue<double>(
            mobile: 48.0,
            tablet: 56.0,
            desktop: 64.0,
          ).of(context);

          final titleSize = ResponsiveValue<double>(
            mobile: 22.0,
            tablet: 26.0,
            desktop: 28.0,
          ).of(context);

          final fieldSpacing = ResponsiveValue<double>(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ).of(context);

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: containerWidth,
                  ),
                  child: Container(
                    width: isMobile ? double.infinity : containerWidth,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      boxShadow: isMobile
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Icon(
                            Icons.admin_panel_settings,
                            size: iconSize,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            S.current.appName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            S.current.welcome,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isMobile ? 24 : 32),

                          // 用户名输入
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: S.current.username,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.current.pleaseEnterUsername;
                              }
                              return null;
                            },
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: fieldSpacing),

                          // 密码输入
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: S.current.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.current.pleaseEnterPassword;
                              }
                              return null;
                            },
                            enabled: !_isLoading,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          SizedBox(height: isMobile ? 20 : 24),

                          // 登录按钮
                          SizedBox(
                            width: double.infinity,
                            height: isMobile ? 44 : 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? _buildShimmerLoading(context)
                                  : Text(
                                      S.current.login,
                                      style: TextStyle(
                                        fontSize: isMobile ? 15 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建 shimmer 加载效果
  Widget _buildShimmerLoading(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  /// 将 MenuInfo 转换为 MenuItem
  MenuItem _convertMenuInfoToMenuItem(MenuInfo menuInfo) {
    return MenuItem(
      id: menuInfo.id?.toString() ?? '',
      name: menuInfo.name ?? '',
      path: menuInfo.path ?? '',
      icon: menuInfo.icon,
      children: menuInfo.children
              ?.map((child) => _convertMenuInfoToMenuItem(child))
              .toList() ??
          const [],
    );
  }
}