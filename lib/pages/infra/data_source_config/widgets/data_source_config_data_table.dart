import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/data_source_config.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 数据源配置数据表格组件
class DataSourceConfigDataTable extends StatelessWidget {
  final List<DataSourceConfig> dataSourceConfigList;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(DataSourceConfig dataSourceConfig) onEdit;
  final void Function(DataSourceConfig dataSourceConfig) onDelete;

  const DataSourceConfigDataTable({
    super.key,
    required this.dataSourceConfigList,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${S.current.loadFailed}: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onReload,
                child: Text(S.current.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (dataSourceConfigList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.dataSourceConfigList),
              const Spacer(),
              Text('${S.current.total}: ${dataSourceConfigList.length}'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: isMobile ? 8 : 12,
              horizontalMargin: isMobile ? 8 : 12,
              minWidth: isMobile ? 500 : 800,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text(S.current.dataSourceConfigId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.dataSourceConfigName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.dataSourceUrl),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.username),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: dataSourceConfigList.map((dataSourceConfig) {
                final isMainDataSource = dataSourceConfig.id == 0;
                return DataRow2(
                  cells: [
                    DataCell(Text(dataSourceConfig.id?.toString() ?? '-')),
                    DataCell(Text(dataSourceConfig.name)),
                    DataCell(Text(dataSourceConfig.url)),
                    DataCell(Text(dataSourceConfig.username)),
                    DataCell(Text(dataSourceConfig.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, dataSourceConfig, isMainDataSource, isMobile)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DataSourceConfig dataSourceConfig, bool isMainDataSource, bool isMobile) {
    if (isMobile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: isMainDataSource ? null : () => onEdit(dataSourceConfig),
            tooltip: S.current.edit,
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: isMainDataSource ? Colors.grey : Colors.red),
            onPressed: isMainDataSource ? null : () => onDelete(dataSourceConfig),
            tooltip: S.current.delete,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: isMainDataSource ? null : () => onEdit(dataSourceConfig),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              enabled: !isMainDataSource,
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: isMainDataSource ? Colors.grey : Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    S.current.delete,
                    style: TextStyle(color: isMainDataSource ? Colors.grey : Colors.red),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'delete':
                onDelete(dataSourceConfig);
                break;
            }
          },
        ),
      ],
    );
  }
}