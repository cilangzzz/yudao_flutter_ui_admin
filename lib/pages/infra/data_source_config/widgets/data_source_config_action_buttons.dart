import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 数据源配置操作按钮组件（工具栏）
class DataSourceConfigActionButtons extends StatelessWidget {
  final VoidCallback onAdd;

  const DataSourceConfigActionButtons({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(S.current.addDataSourceConfig),
          ),
        ],
      ),
    );
  }
}