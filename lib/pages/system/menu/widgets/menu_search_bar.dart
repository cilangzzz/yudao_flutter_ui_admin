import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 菜单搜索栏组件
class MenuSearchBar extends StatelessWidget {
  /// 搜索控制器
  final TextEditingController searchController;

  /// 搜索回调
  final VoidCallback onSearch;

  /// 重置回调
  final VoidCallback onReset;

  const MenuSearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 搜索框
          SizedBox(
            width: 220,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: S.current.searchMenuName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: () {
              searchController.clear();
              onReset();
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }
}