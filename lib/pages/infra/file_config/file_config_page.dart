import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/file_config_api.dart';
import '../../../models/infra/file_config.dart';
import '../../../i18n/i18n.dart';
import 'widgets/file_config_search_form.dart';
import 'widgets/file_config_action_buttons.dart';
import 'widgets/file_config_data_table.dart';
import 'dialogs/file_config_form_dialog.dart';

/// 文件配置管理页面
class FileConfigPage extends ConsumerStatefulWidget {
  const FileConfigPage({super.key});

  @override
  ConsumerState<FileConfigPage> createState() => _FileConfigPageState();
}

class _FileConfigPageState extends ConsumerState<FileConfigPage> {
  final _nameController = TextEditingController();
  int? _selectedStorage;
  DateTimeRange? _dateRange;

  List<FileConfig> _configList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadConfigList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final configApi = ref.read(fileConfigApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedStorage != null) 'storage': _selectedStorage,
        if (_dateRange != null) ...{
          'createTime': [
            _dateRange!.start.toIso8601String().substring(0, 10),
            _dateRange!.end.toIso8601String().substring(0, 10),
          ].join(','),
        },
      };

      final response = await configApi.getFileConfigPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _configList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
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
    setState(() {
      _selectedStorage = null;
      _dateRange = null;
      _currentPage = 1;
    });
    _loadConfigList();
  }

  Future<void> _deleteConfig(FileConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteFileConfig} "${config.name}" ?'),
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
        final configApi = ref.read(fileConfigApiProvider);
        final response = await configApi.deleteFileConfig(config.id!);

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

  Future<void> _deleteBatch() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteBatch} (${_selectedIds.length} ${S.current.items})?'),
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
        final configApi = ref.read(fileConfigApiProvider);
        final response = await configApi.deleteFileConfigList(_selectedIds.toList());

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

  Future<void> _setMaster(FileConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.setMasterConfig),
        content: Text('${S.current.confirmSetMasterConfig} "${config.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final configApi = ref.read(fileConfigApiProvider);
        final response = await configApi.updateFileConfigMaster(config.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.operationSuccess)),
            );
            _loadConfigList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.operationFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _testConfig(FileConfig config) async {
    try {
      final configApi = ref.read(fileConfigApiProvider);
      final response = await configApi.testFileConfig(config.id!);

      if (response.isSuccess) {
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.current.testUploadSuccess),
              content: Text(S.current.confirmOpenFile),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(S.current.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(S.current.visit),
                ),
              ],
            ),
          );

          if (shouldOpen == true && response.data != null) {
            // 使用 url_launcher 打开链接
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.testFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.testFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          FileConfigSearchForm(
            nameController: _nameController,
            selectedStorage: _selectedStorage,
            dateRange: _dateRange,
            onStorageChanged: (value) => setState(() => _selectedStorage = value),
            onDateRangeChanged: (value) => setState(() => _dateRange = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          FileConfigActionButtons(
            onAdd: () => showFileConfigFormDialog(
              context,
              ref: ref,
              onSuccess: _loadConfigList,
            ),
            onDeleteBatch: _selectedIds.isNotEmpty ? _deleteBatch : null,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: FileConfigDataTable(
              configList: _configList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              selectedIds: _selectedIds,
              onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
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
              onEdit: (config) => showFileConfigFormDialog(
                context,
                config: config,
                ref: ref,
                onSuccess: _loadConfigList,
              ),
              onDelete: _deleteConfig,
              onSetMaster: _setMaster,
              onTest: _testConfig,
            ),
          ),
        ],
      ),
    );
  }
}