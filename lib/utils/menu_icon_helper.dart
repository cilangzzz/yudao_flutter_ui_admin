import 'package:flutter/material.dart';

/// 菜单图标工具类
/// 提供图标名称与 IconData 的映射
class MenuIconHelper {
  MenuIconHelper._();

  /// 常见图标映射
  static const Map<String, IconData> _iconMap = {
    'settings': Icons.settings,
    'people': Icons.people,
    'admin_panel_settings': Icons.admin_panel_settings,
    'menu': Icons.menu,
    'monitor': Icons.monitor,
    'online_prediction': Icons.online_prediction,
    'history': Icons.history,
    'dashboard': Icons.dashboard,
    'folder': Icons.folder,
    'home': Icons.home,
    'user': Icons.person,
    'role': Icons.admin_panel_settings,
    'dept': Icons.business,
    'post': Icons.work,
    'dict': Icons.book,
    'config': Icons.settings,
    'log': Icons.article,
    'notice': Icons.notifications,
    'file': Icons.insert_drive_file,
    'table': Icons.table_chart,
    'chart': Icons.bar_chart,
    'form': Icons.edit_note,
    'list': Icons.list,
    'tree': Icons.account_tree,
    'search': Icons.search,
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'refresh': Icons.refresh,
    'export': Icons.download,
    'import': Icons.upload,
  };

  /// 根据图标名称获取 IconData
  /// [iconName] 图标名称，不区分大小写
  /// 返回对应的 IconData，如果未找到则返回默认的文件夹图标
  static IconData getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.folder;
    }
    return _iconMap[iconName.toLowerCase()] ?? Icons.folder;
  }
}