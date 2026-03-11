import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/codegen_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/codegen.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/codegen_search_form.dart';
import 'widgets/codegen_action_buttons.dart';
import 'widgets/codegen_data_table.dart';
import 'dialogs/import_table_dialog.dart';
import 'dialogs/preview_code_dialog.dart';
import 'dialogs/codegen_edit_dialog.dart';

/// 代码生成页面
class CodegenPage extends ConsumerStatefulWidget {
  const CodegenPage({super.key});

  @override
  ConsumerState<CodegenPage> createState() => _CodegenPageState();
}

class _CodegenPageState extends ConsumerState<CodegenPage> {
  final _tableNameController = TextEditingController();
  final _tableCommentController = TextEditingController();

  List<CodegenTable> _tableList = [];
  List<DataSourceConfig> _dataSourceList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  List<int> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _loadDataSourceList();
    _loadTableList();
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    _tableCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadDataSourceList() async {
    try {
      final api = ref.read(dataSourceConfigApiProvider);
      final response = await api.getDataSourceConfigList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataSourceList = response.data!;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadTableList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(codegenApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_tableNameController.text.isNotEmpty) 'tableName': _tableNameController.text,
        if (_tableCommentController.text.isNotEmpty) 'tableComment': _tableCommentController.text,
      };

      final response = await api.getCodegenTablePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _tableList = response.data!.list;
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
    _loadTableList();
  }

  void _reset() {
    _tableNameController.clear();
    _tableCommentController.clear();
    setState(() {
      _currentPage = 1;
    });
    _loadTableList();
  }

  Future<void> _importTable() async {
    final result = await showImportTableDialog(
      context,
      ref: ref,
      dataSourceList: _dataSourceList,
    );
    if (result == true) {
      _loadTableList();
    }
  }

  Future<void> _previewCode(CodegenTable table) async {
    await showPreviewCodeDialog(
      context,
      ref: ref,
      table: table,
    );
  }

  void _editTable(CodegenTable table) {
    showCodegenEditDialog(
      context,
      ref: ref,
      tableId: table.id!,
      onSuccess: _loadTableList,
    );
  }

  Future<void> _syncFromDB(CodegenTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmSync),
        content: Text('${S.current.confirmSyncTable} "${table.tableName}" ?'),
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
        final api = ref.read(codegenApiProvider);
        final response = await api.syncCodegenFromDB(table.id!);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.syncSuccess)),
            );
            _loadTableList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.syncFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.syncFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _generateCode(CodegenTable table) async {
    try {
      final api = ref.read(codegenApiProvider);
      final response = await api.downloadCodegen(table.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.generateSuccess)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.generateFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.generateFailed}: $e')),
        );
      }
    }
  }

  Future<void> _deleteTable(CodegenTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteTable} "${table.tableName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(codegenApiProvider);
        final response = await api.deleteCodegenTable(table.id!);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadTableList();
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
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDeleteBatch),
        content: Text('${S.current.confirmDeleteTables} (${_selectedIds.length}) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(codegenApiProvider);
        final response = await api.deleteCodegenTableList(_selectedIds);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            setState(() => _selectedIds = []);
            _loadTableList();
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
          CodegenSearchForm(
            tableNameController: _tableNameController,
            tableCommentController: _tableCommentController,
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          CodegenActionButtons(
            onImport: _importTable,
            onDeleteBatch: _selectedIds.isNotEmpty ? _deleteBatch : null,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: CodegenDataTable(
              tableList: _tableList,
              dataSourceList: _dataSourceList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              selectedIds: _selectedIds,
              onReload: _loadTableList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadTableList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadTableList();
              },
              onSelectionChanged: (ids) {
                setState(() => _selectedIds = ids);
              },
              onPreview: _previewCode,
              onEdit: _editTable,
              onSync: _syncFromDB,
              onGenerate: _generateCode,
              onDelete: _deleteTable,
            ),
          ),
        ],
      ),
    );
  }
}