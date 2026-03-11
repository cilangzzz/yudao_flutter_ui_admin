import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/router.dart';
import '../../stores/stores.dart';
import '../../api/core/auth_api.dart';
import '../../models/core/auth_models.dart';
import '../../i18n/i18n.dart';

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
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  S.current.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.current.welcome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            S.current.login,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
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