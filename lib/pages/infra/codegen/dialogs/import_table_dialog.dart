import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/codegen_api.dart';
import '../../../models/infra/codegen.dart';
import '../../../i18n/i18n.dart';

/// 导入表对话框
class ImportTableDialog extends StatefulWidget {
  final WidgetRef ref;
  final List<DataSourceConfig> dataSourceList;

  const ImportTableDialog({
    super.key,
    required this.ref,
    required this.dataSourceList,
  });

  @override
  State<ImportTableDialog> createState() => _ImportTableDialogState();
}

class _ImportTableDialogState extends State<ImportTableDialog> {
  int? _selectedDataSourceId;
  final _tableNameController = TextEditingController();
  final _tableCommentController = TextEditingController();

  List<DatabaseTable> _tableList = [];
  List<String> _selectedTableNames = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.dataSourceList.isNotEmpty) {
      _selectedDataSourceId = widget.dataSourceList.first.id;
      _loadTableList();
    }
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    _tableCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadTableList() async {
    if (_selectedDataSourceId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = widget.ref.read(codegenApiProvider);
      final params = {
        'dataSourceConfigId': _selectedDataSourceId,
        if (_tableNameController.text.isNotEmpty) 'name': _tableNameController.text,
        if (_tableCommentController.text.isNotEmpty) 'comment': _tableCommentController.text,
      };

      final response = await api.getSchemaTableList(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _tableList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.loadFailed)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.loadFailed}: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedDataSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectDataSource)),
      );
      return;
    }

    if (_selectedTableNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectTable)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final api = widget.ref.read(codegenApiProvider);
      final request = CodegenCreateReq(
        dataSourceConfigId: _selectedDataSourceId,
        tableNames: _selectedTableNames,
      );

      final response = await api.createCodegenList(request);
      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.importSuccess)),
          );
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.importFailed)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.importFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.importTable),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            // 搜索栏
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDataSourceId,
                    decoration: InputDecoration(
                      labelText: S.current.dataSource,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: widget.dataSourceList.map((ds) {
                      return DropdownMenuItem(
                        value: ds.id,
                        child: Text(ds.name ?? '-'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDataSourceId = value;
                        _selectedTableNames = [];
                      });
                      _loadTableList();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _tableNameController,
                    decoration: InputDecoration(
                      labelText: S.current.tableName,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _tableCommentController,
                    decoration: InputDecoration(
                      labelText: S.current.tableComment,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadTableList,
                  child: Text(S.current.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 表格
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: _selectedTableNames.length == _tableList.length && _tableList.isNotEmpty,
                            tristate: true,
                            onChanged: (value) {
                              if (value == true) {
                                setState(() {
                                  _selectedTableNames = _tableList.map((e) => e.name ?? '').toList();
                                });
                              } else {
                                setState(() {
                                  _selectedTableNames = [];
                                });
                              }
                            },
                          ),
                        ),
                        DataColumn(label: Text(S.current.tableName)),
                        DataColumn(label: Text(S.current.tableComment)),
                      ],
                      rows: _tableList.map((table) {
                        final isSelected = _selectedTableNames.contains(table.name);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (value) {
                            if (value == true) {
                              setState(() {
                                _selectedTableNames.add(table.name ?? '');
                              });
                            } else {
                              setState(() {
                                _selectedTableNames.remove(table.name);
                              });
                            }
                          },
                          cells: [
                            DataCell(Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (value == true) {
                                  setState(() {
                                    _selectedTableNames.add(table.name ?? '');
                                  });
                                } else {
                                  setState(() {
                                    _selectedTableNames.remove(table.name);
                                  });
                                }
                              },
                            )),
                            DataCell(Text(table.name ?? '-')),
                            DataCell(Text(table.comment ?? '-')),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示导入表对话框的便捷方法
Future<bool?> showImportTableDialog(
  BuildContext context, {
  required WidgetRef ref,
  required List<DataSourceConfig> dataSourceList,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ImportTableDialog(
      ref: ref,
      dataSourceList: dataSourceList,
    ),
  );
}