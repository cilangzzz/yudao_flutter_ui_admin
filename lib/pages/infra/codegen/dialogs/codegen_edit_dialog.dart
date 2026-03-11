import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/codegen_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_type_api.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/infra/codegen.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_type.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 代码生成编辑对话框
class CodegenEditDialog extends StatefulWidget {
  final WidgetRef ref;
  final int tableId;
  final VoidCallback onSuccess;

  const CodegenEditDialog({
    super.key,
    required this.ref,
    required this.tableId,
    required this.onSuccess,
  });

  @override
  State<CodegenEditDialog> createState() => _CodegenEditDialogState();
}

class _CodegenEditDialogState extends State<CodegenEditDialog> {
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  CodegenDetail? _detail;
  List<CodegenTable> _tables = [];
  List<SimpleDictType> _dictTypes = [];

  // 基本信息表单控制器
  final _tableNameController = TextEditingController();
  final _tableCommentController = TextEditingController();
  final _classNameController = TextEditingController();
  final _authorController = TextEditingController();
  final _remarkController = TextEditingController();

  // 生成信息表单控制器
  int? _templateType;
  int? _frontType;
  int? _scene;
  int? _parentMenuId;
  final _moduleNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _genClassNameController = TextEditingController();
  final _classCommentController = TextEditingController();

  // 树表信息
  int? _treeParentColumnId;
  int? _treeNameColumnId;

  // 主子表信息
  int? _masterTableId;
  int? _subJoinColumnId;
  bool _subJoinMany = true;

  // 字段信息列表
  List<CodegenColumn> _columns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    _tableCommentController.dispose();
    _classNameController.dispose();
    _authorController.dispose();
    _remarkController.dispose();
    _moduleNameController.dispose();
    _businessNameController.dispose();
    _genClassNameController.dispose();
    _classCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 并行加载数据
      final results = await Future.wait([
        widget.ref.read(codegenApiProvider).getCodegenTable(widget.tableId),
        widget.ref.read(dictTypeApiProvider).getSimpleDictTypeList(),
      ]);

      final detailResponse = results[0] as ApiResponse<CodegenDetail>;
      final dictTypeResponse = results[1] as ApiResponse<List<SimpleDictType>>;

      if (detailResponse.isSuccess && detailResponse.data != null) {
        _detail = detailResponse.data!;

        // 加载同数据源的表列表（用于主子表选择）
        if (_detail!.table?.dataSourceConfigId != null) {
          final tablesResponse = await widget.ref
              .read(codegenApiProvider)
              .getCodegenTableList(_detail!.table!.dataSourceConfigId!);
          if (tablesResponse.isSuccess && tablesResponse.data != null) {
            _tables = tablesResponse.data!;
          }
        }

        // 初始化基本信息表单
        _tableNameController.text = _detail!.table?.tableName ?? '';
        _tableCommentController.text = _detail!.table?.tableComment ?? '';
        _classNameController.text = _detail!.table?.className ?? '';
        _authorController.text = _detail!.table?.author ?? '';
        _remarkController.text = _detail!.table?.remark ?? '';

        // 初始化生成信息表单
        _templateType = _detail!.table?.templateType;
        _frontType = _detail!.table?.frontType;
        _scene = _detail!.table?.scene;
        _parentMenuId = _detail!.table?.parentMenuId;
        _moduleNameController.text = _detail!.table?.moduleName ?? '';
        _businessNameController.text = _detail!.table?.businessName ?? '';
        _genClassNameController.text = _detail!.table?.className ?? '';
        _classCommentController.text = _detail!.table?.classComment ?? '';

        // 树表信息
        _treeParentColumnId = _detail!.table?.treeParentColumnId;
        _treeNameColumnId = _detail!.table?.treeNameColumnId;

        // 主子表信息
        _masterTableId = _detail!.table?.masterTableId;
        _subJoinColumnId = _detail!.table?.subJoinColumnId;
        _subJoinMany = _detail!.table?.subJoinMany ?? true;

        // 字段信息
        _columns = List.from(_detail!.columns);
      }

      if (dictTypeResponse.isSuccess && dictTypeResponse.data != null) {
        _dictTypes = dictTypeResponse.data!;
      }

      setState(() {
        _isLoading = false;
      });
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

  bool _isTreeTable() => _templateType == 2; // InfraCodegenTemplateTypeEnum.TREE

  bool _isSubTable() => _templateType == 3; // InfraCodegenTemplateTypeEnum.SUB

  Future<void> _submit() async {
    // 验证基本信息
    if (_tableNameController.text.isEmpty ||
        _tableCommentController.text.isEmpty ||
        _classNameController.text.isEmpty ||
        _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    // 验证生成信息
    if (_moduleNameController.text.isEmpty ||
        _businessNameController.text.isEmpty ||
        _genClassNameController.text.isEmpty ||
        _classCommentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final table = CodegenTable(
        id: _detail!.table?.id,
        tableName: _tableNameController.text,
        tableComment: _tableCommentController.text,
        className: _classNameController.text,
        author: _authorController.text,
        remark: _remarkController.text,
        templateType: _templateType,
        frontType: _frontType,
        scene: _scene,
        parentMenuId: _parentMenuId,
        moduleName: _moduleNameController.text,
        businessName: _businessNameController.text,
        classComment: _classCommentController.text,
        treeParentColumnId: _treeParentColumnId,
        treeNameColumnId: _treeNameColumnId,
        masterTableId: _masterTableId,
        subJoinColumnId: _subJoinColumnId,
        subJoinMany: _subJoinMany,
        dataSourceConfigId: _detail!.table?.dataSourceConfigId,
      );

      final request = CodegenUpdateReq(
        table: table,
        columns: _columns,
      );

      final api = widget.ref.read(codegenApiProvider);
      final response = await api.updateCodegenTable(request);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.saveSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.saveFailed)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.saveFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Text(
                    S.current.editCodegen,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 步骤指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildStep(0, S.current.basicInfo),
                  _buildStepLine(1),
                  _buildStep(1, S.current.columnInfo),
                  _buildStepLine(2),
                  _buildStep(2, S.current.generationInfo),
                ],
              ),
            ),
            const Divider(height: 1),
            // 内容区域
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildStepContent(),
                    ),
            ),
            // 底部按钮
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: Text(S.current.prevStep),
                    ),
                  const SizedBox(width: 8),
                  if (_currentStep < 2)
                    ElevatedButton(
                      onPressed: () => setState(() => _currentStep++),
                      child: Text(S.current.nextStep),
                    ),
                  if (_currentStep == 2) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(S.current.save),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String title) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;

    return InkWell(
      onTap: () => setState(() => _currentStep = index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : isCompleted
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 18)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: _currentStep >= index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoForm();
      case 1:
        return _buildColumnInfoForm();
      case 2:
        return _buildGenerationInfoForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.basicInfo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tableNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.tableName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _tableCommentController,
                decoration: InputDecoration(
                  labelText: '${S.current.tableComment} *',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _classNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.className} *',
                  border: const OutlineInputBorder(),
                  helperText: S.current.classNameHelp,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: '${S.current.author} *',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _remarkController,
          decoration: InputDecoration(
            labelText: S.current.remark,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildColumnInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.columnInfo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            columns: [
              DataColumn(label: Text(S.current.columnName)),
              DataColumn(label: Text(S.current.columnComment)),
              DataColumn(label: Text(S.current.dataType)),
              DataColumn(label: Text(S.current.javaType)),
              DataColumn(label: Text(S.current.javaField)),
              DataColumn(label: Text(S.current.insert)),
              DataColumn(label: Text(S.current.edit)),
              DataColumn(label: Text(S.current.list)),
              DataColumn(label: Text(S.current.query)),
              DataColumn(label: Text(S.current.queryType)),
              DataColumn(label: Text(S.current.nullable)),
              DataColumn(label: Text(S.current.htmlType)),
              DataColumn(label: Text(S.current.dictType)),
              DataColumn(label: Text(S.current.example)),
            ],
            rows: _columns.map((column) {
              return DataRow(
                cells: [
                  DataCell(Text(column.columnName ?? '-')),
                  DataCell(TextField(
                    controller: TextEditingController(text: column.columnComment),
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(columnComment: value);
                    },
                  )),
                  DataCell(Text(column.dataType ?? '-')),
                  DataCell(_buildJavaTypeDropdown(column)),
                  DataCell(TextField(
                    controller: TextEditingController(text: column.javaField),
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(javaField: value);
                    },
                  )),
                  DataCell(Checkbox(
                    value: column.createOperation == 1,
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(createOperation: value == true ? 1 : 0);
                      setState(() {});
                    },
                  )),
                  DataCell(Checkbox(
                    value: column.updateOperation == 1,
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(updateOperation: value == true ? 1 : 0);
                      setState(() {});
                    },
                  )),
                  DataCell(Checkbox(
                    value: column.listOperationResult == 1,
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(listOperationResult: value == true ? 1 : 0);
                      setState(() {});
                    },
                  )),
                  DataCell(Checkbox(
                    value: column.listOperation == 1,
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(listOperation: value == true ? 1 : 0);
                      setState(() {});
                    },
                  )),
                  DataCell(_buildQueryTypeDropdown(column)),
                  DataCell(Checkbox(
                    value: column.nullable == 1,
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(nullable: value == true ? 1 : 0);
                      setState(() {});
                    },
                  )),
                  DataCell(_buildHtmlTypeDropdown(column)),
                  DataCell(_buildDictTypeDropdown(column)),
                  DataCell(TextField(
                    controller: TextEditingController(text: column.example),
                    onChanged: (value) {
                      final index = _columns.indexOf(column);
                      _columns[index] = column.copyWith(example: value);
                    },
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJavaTypeDropdown(CodegenColumn column) {
    final options = ['Long', 'String', 'Integer', 'Double', 'BigDecimal', 'LocalDateTime', 'Boolean'];
    return DropdownButton<String>(
      value: column.javaType,
      isDense: true,
      underline: const SizedBox(),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {
        if (value != null) {
          final index = _columns.indexOf(column);
          _columns[index] = column.copyWith(javaType: value);
          setState(() {});
        }
      },
    );
  }

  Widget _buildQueryTypeDropdown(CodegenColumn column) {
    final options = ['=', '!=', '>', '>=', '<', '<=', 'LIKE', 'BETWEEN'];
    return DropdownButton<String>(
      value: column.listOperationCondition,
      isDense: true,
      underline: const SizedBox(),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {
        if (value != null) {
          final index = _columns.indexOf(column);
          _columns[index] = column.copyWith(listOperationCondition: value);
          setState(() {});
        }
      },
    );
  }

  Widget _buildHtmlTypeDropdown(CodegenColumn column) {
    final options = [
      {'value': 'input', 'label': S.current.htmlTypeInput},
      {'value': 'textarea', 'label': S.current.htmlTypeTextarea},
      {'value': 'select', 'label': S.current.htmlTypeSelect},
      {'value': 'radio', 'label': S.current.htmlTypeRadio},
      {'value': 'checkbox', 'label': S.current.htmlTypeCheckbox},
      {'value': 'datetime', 'label': S.current.htmlTypeDatetime},
      {'value': 'imageUpload', 'label': S.current.htmlTypeImageUpload},
      {'value': 'fileUpload', 'label': S.current.htmlTypeFileUpload},
      {'value': 'editor', 'label': S.current.htmlTypeEditor},
    ];
    return DropdownButton<String>(
      value: column.htmlType,
      isDense: true,
      underline: const SizedBox(),
      items: options.map((e) => DropdownMenuItem(
        value: e['value'] as String,
        child: Text(e['label'] as String),
      )).toList(),
      onChanged: (value) {
        if (value != null) {
          final index = _columns.indexOf(column);
          _columns[index] = column.copyWith(htmlType: value);
          setState(() {});
        }
      },
    );
  }

  Widget _buildDictTypeDropdown(CodegenColumn column) {
    return DropdownButton<String>(
      value: column.dictType?.isNotEmpty == true ? column.dictType : null,
      isDense: true,
      underline: const SizedBox(),
      hint: Text(S.current.selectDictType),
      items: _dictTypes.map((e) => DropdownMenuItem(
        value: e.type,
        child: Text(e.name ?? ''),
      )).toList(),
      onChanged: (value) {
        final index = _columns.indexOf(column);
        _columns[index] = column.copyWith(dictType: value);
        setState(() {});
      },
    );
  }

  Widget _buildGenerationInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.generationInfo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _templateType,
                decoration: InputDecoration(
                  labelText: '${S.current.templateType} *',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text(S.current.templateTypeSingle)),
                  DropdownMenuItem(value: 2, child: Text(S.current.templateTypeTree)),
                  DropdownMenuItem(value: 3, child: Text(S.current.templateTypeMasterSub)),
                ],
                onChanged: (value) {
                  setState(() => _templateType = value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _frontType,
                decoration: InputDecoration(
                  labelText: '${S.current.frontType} *',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 10, child: Text(S.current.frontTypeVue3)),
                  DropdownMenuItem(value: 20, child: Text(S.current.frontTypeVue2)),
                ],
                onChanged: (value) {
                  setState(() => _frontType = value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _scene,
                decoration: InputDecoration(
                  labelText: '${S.current.scene} *',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text(S.current.sceneAdmin)),
                  DropdownMenuItem(value: 2, child: Text(S.current.sceneApp)),
                ],
                onChanged: (value) {
                  setState(() => _scene = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _moduleNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.moduleName} *',
                  border: const OutlineInputBorder(),
                  helperText: S.current.moduleNameHelp,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.businessName} *',
                  border: const OutlineInputBorder(),
                  helperText: S.current.businessNameHelp,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _genClassNameController,
                decoration: InputDecoration(
                  labelText: '${S.current.className} *',
                  border: const OutlineInputBorder(),
                  helperText: S.current.classNameHelp2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _classCommentController,
                decoration: InputDecoration(
                  labelText: '${S.current.classComment} *',
                  border: const OutlineInputBorder(),
                  helperText: S.current.classCommentHelp,
                ),
              ),
            ),
          ],
        ),
        // 树表信息
        if (_isTreeTable()) ...[
          const SizedBox(height: 24),
          Text(S.current.treeTableInfo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _treeParentColumnId,
                  decoration: InputDecoration(
                    labelText: '${S.current.treeParentColumn} *',
                    border: const OutlineInputBorder(),
                    helperText: S.current.treeParentColumnHelp,
                  ),
                  items: _columns.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.columnName ?? ''),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _treeParentColumnId = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _treeNameColumnId,
                  decoration: InputDecoration(
                    labelText: '${S.current.treeNameColumn} *',
                    border: const OutlineInputBorder(),
                    helperText: S.current.treeNameColumnHelp,
                  ),
                  items: _columns.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.columnName ?? ''),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _treeNameColumnId = value);
                  },
                ),
              ),
            ],
          ),
        ],
        // 主子表信息
        if (_isSubTable()) ...[
          const SizedBox(height: 24),
          Text(S.current.masterSubTableInfo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _masterTableId,
                  decoration: InputDecoration(
                    labelText: '${S.current.masterTable} *',
                    border: const OutlineInputBorder(),
                    helperText: S.current.masterTableHelp,
                  ),
                  items: _tables.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.tableName}: ${e.tableComment}'),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _masterTableId = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _subJoinColumnId,
                  decoration: InputDecoration(
                    labelText: '${S.current.subJoinColumn} *',
                    border: const OutlineInputBorder(),
                    helperText: S.current.subJoinColumnHelp,
                  ),
                  items: _columns.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.columnName}: ${e.columnComment}'),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _subJoinColumnId = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(S.current.relationType),
              const SizedBox(width: 16),
              Radio<bool>(
                value: true,
                groupValue: _subJoinMany,
                onChanged: (value) {
                  setState(() => _subJoinMany = value ?? true);
                },
              ),
              Text(S.current.relationOneToOne),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _subJoinMany,
                onChanged: (value) {
                  setState(() => _subJoinMany = value ?? false);
                },
              ),
              Text(S.current.relationOneToMany),
            ],
          ),
        ],
      ],
    );
  }
}

/// 显示代码生成编辑对话框的便捷方法
void showCodegenEditDialog(
  BuildContext context, {
  required WidgetRef ref,
  required int tableId,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => CodegenEditDialog(
      ref: ref,
      tableId: tableId,
      onSuccess: onSuccess,
    ),
  );
}