import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/config_api.dart';
import '../../../models/infra/config.dart';
import '../../../i18n/i18n.dart';
import 'widgets/config_search_form.dart';
import 'widgets/config_action_buttons.dart';
import 'widgets/config_data_table.dart';
import 'dialogs/config_form_dialog.dart';

/// 参数配置管理页面
class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  int? _selectedType;
  DateTimeRange? _createTimeRange;

  List<Config> _configList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfigList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final configApi = ref.read(configApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_keyController.text.isNotEmpty) 'key': _keyController.text,
        if (_selectedType != null) 'type': _selectedType,
        if (_createTimeRange != null) ...{
          'createTime': [
            _createTimeRange!.start.toIso8601String(),
            _createTimeRange!.end.toIso8601String(),
          ],
        },
      };

      final response = await configApi.getConfigPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _configList = response.data!.list;
          _totalCount = response.data!.total;
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

  void _search() {
    setState(() => _currentPage = 1);
    _loadConfigList();
  }

  void _reset() {
    _nameController.clear();
    _keyController.clear();
    setState(() {
      _selectedType = null;
      _createTimeRange = null;
      _currentPage = 1;
    });
    _loadConfigList();
  }

  Future<void> _deleteConfig(Config config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteConfig} "${config.name}" ?'),
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
        final configApi = ref.read(configApiProvider);
        final response = await configApi.deleteConfig(config.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadConfigList();
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
          // 搜索栏
          ConfigSearchForm(
            nameController: _nameController,
            keyController: _keyController,
            selectedType: _selectedType,
            createTimeRange: _createTimeRange,
            onTypeChanged: (value) => setState(() => _selectedType = value),
            onCreateTimeRangeChanged: (value) => setState(() => _createTimeRange = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          ConfigActionButtons(
            onAdd: () => showConfigFormDialog(
              context,
              ref: ref,
              onSuccess: _loadConfigList,
            ),
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: ConfigDataTable(
              configList: _configList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadConfigList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadConfigList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadConfigList();
              },
              onEdit: (config) => showConfigFormDialog(
                context,
                config: config,
                ref: ref,
                onSuccess: _loadConfigList,
              ),
              onDelete: _deleteConfig,
            ),
          ),
        ],
      ),
    );
  }
}