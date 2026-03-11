import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/data_source_config_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/data_source_config.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/data_source_config_data_table.dart';
import 'widgets/data_source_config_action_buttons.dart';
import 'dialogs/data_source_config_form_dialog.dart';

/// 数据源配置管理页面
class DataSourceConfigPage extends ConsumerStatefulWidget {
  const DataSourceConfigPage({super.key});

  @override
  ConsumerState<DataSourceConfigPage> createState() => _DataSourceConfigPageState();
}

class _DataSourceConfigPageState extends ConsumerState<DataSourceConfigPage> {
  List<DataSourceConfig> _dataSourceConfigList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDataSourceConfigList();
  }

  Future<void> _loadDataSourceConfigList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSourceConfigApi = ref.read(dataSourceConfigApiProvider);
      final response = await dataSourceConfigApi.getDataSourceConfigList();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataSourceConfigList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg ?? S.current.loadFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDataSourceConfig(DataSourceConfig dataSourceConfig) async {
    // 主数据源（id=0）不能删除
    if (dataSourceConfig.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.cannotDeleteMainDataSource)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDataSourceConfig} "${dataSourceConfig.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dataSourceConfigApi = ref.read(dataSourceConfigApiProvider);
        final response = await dataSourceConfigApi.deleteDataSourceConfig(dataSourceConfig.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDataSourceConfigList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏
          DataSourceConfigActionButtons(
            onAdd: () => showDataSourceConfigFormDialog(
              context,
              ref: ref,
              onSuccess: _loadDataSourceConfigList,
            ),
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: DataSourceConfigDataTable(
              dataSourceConfigList: _dataSourceConfigList,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadDataSourceConfigList,
              onEdit: (dataSourceConfig) => showDataSourceConfigFormDialog(
                context,
                dataSourceConfig: dataSourceConfig,
                ref: ref,
                onSuccess: _loadDataSourceConfigList,
              ),
              onDelete: _deleteDataSourceConfig,
            ),
          ),
        ],
      ),
    );
  }
}