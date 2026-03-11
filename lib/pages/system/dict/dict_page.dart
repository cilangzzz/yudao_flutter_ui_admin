import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/dict_type_api.dart';
import '../../../api/system/dict_data_api.dart';
import '../../../models/system/dict_type.dart';
import '../../../models/system/dict_data.dart';
import '../../../models/common/page_param.dart';
import '../../../i18n/i18n.dart';

/// 字典管理主页面
/// 左侧显示字典类型列表，右侧显示字典数据列表
class DictPage extends ConsumerStatefulWidget {
  const DictPage({super.key});

  @override
  ConsumerState<DictPage> createState() => _DictPageState();
}

class _DictPageState extends ConsumerState<DictPage> {
  // ==================== 字典类型状态 ====================
  final _typeSearchController = TextEditingController();
  int? _typeStatusFilter;
  List<DictType> _dictTypeList = [];
  Set<int> _selectedTypeIds = {};
  int _typeTotalCount = 0;
  int _typeCurrentPage = 1;
  int _typePageSize = 10;
  bool _typeIsLoading = true;
  String? _typeError;

  // ==================== 字典数据状态 ====================
  String? _selectedDictType;
  final _dataSearchController = TextEditingController();
  int? _dataStatusFilter;
  List<DictData> _dictDataList = [];
  Set<int> _selectedDataIds = {};
  int _dataTotalCount = 0;
  int _dataCurrentPage = 1;
  int _dataPageSize = 10;
  bool _dataIsLoading = false;
  String? _dataError;

  @override
  void initState() {
    super.initState();
    _loadDictTypeList();
  }

  @override
  void dispose() {
    _typeSearchController.dispose();
    _dataSearchController.dispose();
    super.dispose();
  }

  // ==================== 字典类型相关方法 ====================

  Future<void> _loadDictTypeList() async {
    setState(() {
      _typeIsLoading = true;
      _typeError = null;
    });

    try {
      final api = ref.read(dictTypeApiProvider);
      final params = PageParam(
        pageNum: _typeCurrentPage,
        pageSize: _typePageSize,
      );

      final response = await api.getDictTypePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dictTypeList = response.data!.list;
          _typeTotalCount = response.data!.total;
          _typeIsLoading = false;
          _selectedTypeIds.clear();
        });
      } else {
        setState(() {
          _typeError = response.msg.isNotEmpty ? response.msg : S.current.loadFailed;
          _typeIsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _typeError = e.toString();
        _typeIsLoading = false;
      });
    }
  }

  void _searchDictType() {
    _typeCurrentPage = 1;
    _loadDictTypeList();
  }

  void _resetDictTypeSearch() {
    _typeSearchController.clear();
    setState(() {
      _typeStatusFilter = null;
    });
    _typeCurrentPage = 1;
    _loadDictTypeList();
  }

  void _handleDictTypeSelect(DictType dictType) {
    setState(() {
      _selectedDictType = dictType.type;
      _dataCurrentPage = 1;
    });
    _loadDictDataList();
  }

  Future<void> _deleteSelectedDictTypes() async {
    if (_selectedTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteSelected} (${_selectedTypeIds.length})?'),
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
        final api = ref.read(dictTypeApiProvider);
        final response = await api.deleteDictTypeList(_selectedTypeIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDictTypeList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
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

  Future<void> _deleteDictType(DictType dictType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDictType} "${dictType.name}" ?'),
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
        final api = ref.read(dictTypeApiProvider);
        final response = await api.deleteDictType(dictType.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDictTypeList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
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

  void _showDictTypeDialog([DictType? dictType]) {
    final nameController = TextEditingController(text: dictType?.name ?? '');
    final typeController = TextEditingController(text: dictType?.type ?? '');
    final remarkController = TextEditingController(text: dictType?.remark ?? '');
    int status = dictType?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dictType == null ? S.current.addDictType : S.current.editDictType),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.dictName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: typeController,
                    enabled: dictType == null, // 编辑时不可修改类型
                    decoration: InputDecoration(
                      labelText: '${S.current.dictType} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('${S.current.status}: '),
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.enabled),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.disabled),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || typeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final data = DictType(
                  id: dictType?.id,
                  name: nameController.text,
                  type: typeController.text,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final api = ref.read(dictTypeApiProvider);
                  final response = dictType == null
                      ? await api.createDictType(data)
                      : await api.updateDictType(data);

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(dictType == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadDictTypeList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 字典数据相关方法 ====================

  Future<void> _loadDictDataList() async {
    if (_selectedDictType == null || _selectedDictType!.isEmpty) {
      setState(() {
        _dictDataList = [];
        _dataIsLoading = false;
      });
      return;
    }

    setState(() {
      _dataIsLoading = true;
      _dataError = null;
    });

    try {
      final api = ref.read(dictDataApiProvider);
      final response = await api.getDictDataPage(
        PageParam(
          pageNum: _dataCurrentPage,
          pageSize: _dataPageSize,
        ),
        dictType: _selectedDictType,
        label: _dataSearchController.text.isNotEmpty ? _dataSearchController.text : null,
        status: _dataStatusFilter,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dictDataList = response.data!.list;
          _dataTotalCount = response.data!.total;
          _dataIsLoading = false;
          _selectedDataIds.clear();
        });
      } else {
        setState(() {
          _dataError = response.msg.isNotEmpty ? response.msg : S.current.loadFailed;
          _dataIsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _dataError = e.toString();
        _dataIsLoading = false;
      });
    }
  }

  void _searchDictData() {
    _dataCurrentPage = 1;
    _loadDictDataList();
  }

  void _resetDictDataSearch() {
    _dataSearchController.clear();
    setState(() {
      _dataStatusFilter = null;
    });
    _dataCurrentPage = 1;
    _loadDictDataList();
  }

  Future<void> _deleteSelectedDictData() async {
    if (_selectedDataIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteSelected} (${_selectedDataIds.length})?'),
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
        final api = ref.read(dictDataApiProvider);
        final response = await api.deleteDictDataList(_selectedDataIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDictDataList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
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

  Future<void> _deleteDictData(DictData dictData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDictData} "${dictData.label}" ?'),
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
        final api = ref.read(dictDataApiProvider);
        final response = await api.deleteDictData(dictData.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDictDataList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
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

  void _showDictDataDialog([DictData? dictData]) {
    final labelController = TextEditingController(text: dictData?.label ?? '');
    final valueController = TextEditingController(text: dictData?.value ?? '');
    final sortController = TextEditingController(text: (dictData?.sort ?? 0).toString());
    final cssClassController = TextEditingController(text: dictData?.cssClass ?? '');
    final remarkController = TextEditingController(text: dictData?.remark ?? '');
    String colorType = dictData?.colorType ?? '';
    int status = dictData?.status ?? 0;

    final colorOptions = [
      {'value': '', 'label': S.current.none, 'color': Colors.grey},
      {'value': 'processing', 'label': S.current.colorPrimary, 'color': Colors.blue},
      {'value': 'success', 'label': S.current.colorSuccess, 'color': Colors.green},
      {'value': 'warning', 'label': S.current.colorWarning, 'color': Colors.orange},
      {'value': 'danger', 'label': S.current.colorDanger, 'color': Colors.red},
      {'value': 'info', 'label': S.current.colorInfo, 'color': Colors.cyan},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dictData == null ? S.current.addDictData : S.current.editDictData),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 字典类型显示
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: _selectedDictType ?? ''),
                    decoration: InputDecoration(
                      labelText: S.current.dictType,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: '${S.current.dataLabel} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: '${S.current.dataValue} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortController,
                    decoration: InputDecoration(
                      labelText: S.current.sort,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: colorType,
                    decoration: InputDecoration(
                      labelText: S.current.colorType,
                      border: const OutlineInputBorder(),
                    ),
                    items: colorOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt['value'] as String,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: opt['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(opt['label'] as String),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        colorType = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cssClassController,
                    decoration: InputDecoration(
                      labelText: S.current.cssClass,
                      border: const OutlineInputBorder(),
                      hintText: S.current.cssClassHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('${S.current.status}: '),
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.enabled),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.disabled),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.isEmpty || valueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final data = DictData(
                  id: dictData?.id,
                  label: labelController.text,
                  value: valueController.text,
                  dictType: _selectedDictType,
                  sort: int.tryParse(sortController.text) ?? 0,
                  colorType: colorType.isEmpty ? null : colorType,
                  cssClass: cssClassController.text.isEmpty ? null : cssClassController.text,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final api = ref.read(dictDataApiProvider);
                  final response = dictData == null
                      ? await api.createDictData(data)
                      : await api.updateDictData(data);

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(dictData == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadDictDataList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== UI 构建方法 ====================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // 左侧字典类型列表
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 搜索栏
                _buildTypeSearchBar(context),
                const Divider(height: 1),
                // 工具栏
                _buildTypeToolbar(context),
                const Divider(height: 1),
                // 数据表格
                Expanded(child: _buildTypeDataTable(context)),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // 右侧字典数据列表
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 搜索栏
                _buildDataSearchBar(context),
                const Divider(height: 1),
                // 工具栏
                _buildDataToolbar(context),
                const Divider(height: 1),
                // 数据表格
                Expanded(child: _buildDataDataTable(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // 字典类型选择器
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${S.current.dictType}: '),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDictType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _dictTypeList.map((type) {
                    return DropdownMenuItem(
                      value: type.type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDictType = value;
                        _dataCurrentPage = 1;
                      });
                      _loadDictDataList();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 字典数据列表
        Expanded(child: _buildDataDataTable(context)),
      ],
    );
  }

  // ==================== 字典类型 UI ====================

  Widget _buildTypeSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _typeSearchController,
              decoration: InputDecoration(
                hintText: S.current.searchDictNameOrType,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _searchDictType(),
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int?>(
              value: _typeStatusFilter,
              decoration: InputDecoration(
                labelText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: (value) {
                setState(() {
                  _typeStatusFilter = value;
                });
                _searchDictType();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _searchDictType,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: _resetDictTypeSearch,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showDictTypeDialog(),
            icon: const Icon(Icons.add),
            label: Text(S.current.addDictType),
          ),
          ElevatedButton.icon(
            onPressed: _selectedTypeIds.isEmpty ? null : _deleteSelectedDictTypes,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
          ),
          const SizedBox(width: 16),
          Text('${S.current.total}: $_typeTotalCount'),
        ],
      ),
    );
  }

  Widget _buildTypeDataTable(BuildContext context) {
    if (_typeIsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_typeError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_typeError', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDictTypeList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_dictTypeList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
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
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.dictName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.dictType),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.remark),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                ),
              ],
              rows: _dictTypeList.map((dictType) {
                final isSelected = dictType.id != null && _selectedTypeIds.contains(dictType.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dictType.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedTypeIds.add(dictType.id!);
                        } else {
                          _selectedTypeIds.remove(dictType.id!);
                        }
                      });
                    }
                  },
                  onTap: () => _handleDictTypeSelect(dictType),
                  cells: [
                    DataCell(Text(dictType.id?.toString() ?? '-')),
                    DataCell(
                      InkWell(
                        onTap: () => _handleDictTypeSelect(dictType),
                        child: Text(
                          dictType.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(dictType.type)),
                    DataCell(_buildStatusChip(dictType.status)),
                    DataCell(Text(dictType.remark ?? '-')),
                    DataCell(Text(
                      dictType.createTime?.toString().substring(0, 19) ?? '-',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showDictTypeDialog(dictType),
                            child: Text(S.current.edit),
                          ),
                          PopupMenuButton<String>(
                            tooltip: S.current.more,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'delete':
                                  _deleteDictType(dictType);
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildTypePagination(context),
        ],
      ),
    );
  }

  Widget _buildTypePagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Text('${S.current.pageSize}: '),
            DropdownButton<int>(
              value: _typePageSize,
              items: [10, 20, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _typePageSize = value;
                    _typeCurrentPage = 1;
                  });
                  _loadDictTypeList();
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _typeCurrentPage > 1
                  ? () {
                      setState(() => _typeCurrentPage--);
                      _loadDictTypeList();
                    }
                  : null,
            ),
            Text('$_typeCurrentPage / ${(_typeTotalCount / _typePageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _typeCurrentPage * _typePageSize < _typeTotalCount
                  ? () {
                      setState(() => _typeCurrentPage++);
                      _loadDictTypeList();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  // ==================== 字典数据 UI ====================

  Widget _buildDataSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${S.current.currentDictType}: ${_selectedDictType ?? S.current.pleaseSelectDictType}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _dataSearchController,
              decoration: InputDecoration(
                hintText: S.current.dataLabel,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _searchDictData(),
            ),
          ),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<int?>(
              value: _dataStatusFilter,
              decoration: InputDecoration(
                labelText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: (value) {
                setState(() {
                  _dataStatusFilter = value;
                });
                _searchDictData();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _selectedDictType == null ? null : _searchDictData,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: _selectedDictType == null ? null : _resetDictDataSearch,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildDataToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _selectedDictType == null ? null : () => _showDictDataDialog(),
            icon: const Icon(Icons.add),
            label: Text(S.current.addDictData),
          ),
          ElevatedButton.icon(
            onPressed: _selectedDataIds.isEmpty ? null : _deleteSelectedDictData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
          ),
          const SizedBox(width: 16),
          Text('${S.current.total}: $_dataTotalCount'),
        ],
      ),
    );
  }

  Widget _buildDataDataTable(BuildContext context) {
    if (_selectedDictType == null) {
      return Center(
        child: Text(S.current.pleaseSelectDictTypeLeft),
      );
    }

    if (_dataIsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dataError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_dataError', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDictDataList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_dictDataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 700,
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
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.dataLabel),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.dataValue),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.sort),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.colorType),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.remark),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                ),
              ],
              rows: _dictDataList.map((dictData) {
                final isSelected = dictData.id != null && _selectedDataIds.contains(dictData.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dictData.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedDataIds.add(dictData.id!);
                        } else {
                          _selectedDataIds.remove(dictData.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(dictData.id?.toString() ?? '-')),
                    DataCell(Text(dictData.label)),
                    DataCell(Text(dictData.value)),
                    DataCell(Text(dictData.sort?.toString() ?? '0')),
                    DataCell(_buildStatusChip(dictData.status)),
                    DataCell(_buildColorChip(dictData.colorType)),
                    DataCell(Text(dictData.remark ?? '-')),
                    DataCell(Text(
                      dictData.createTime?.toString().substring(0, 19) ?? '-',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showDictDataDialog(dictData),
                            child: Text(S.current.edit),
                          ),
                          PopupMenuButton<String>(
                            tooltip: S.current.more,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'delete':
                                  _deleteDictData(dictData);
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildDataPagination(context),
        ],
      ),
    );
  }

  Widget _buildDataPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Text('${S.current.pageSize}: '),
            DropdownButton<int>(
              value: _dataPageSize,
              items: [10, 20, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dataPageSize = value;
                    _dataCurrentPage = 1;
                  });
                  _loadDictDataList();
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _dataCurrentPage > 1
                  ? () {
                      setState(() => _dataCurrentPage--);
                      _loadDictDataList();
                    }
                  : null,
            ),
            Text('$_dataCurrentPage / ${(_dataTotalCount / _dataPageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _dataCurrentPage * _dataPageSize < _dataTotalCount
                  ? () {
                      setState(() => _dataCurrentPage++);
                      _loadDictDataList();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  // ==================== 辅助组件 ====================

  Widget _buildStatusChip(int? status) {
    final isEnabled = status == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEnabled ? S.current.enabled : S.current.disabled,
        style: TextStyle(
          color: isEnabled ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColorChip(String? colorType) {
    if (colorType == null || colorType.isEmpty) {
      return const Text('-');
    }

    Color color;
    switch (colorType) {
      case 'processing':
        color = Colors.blue;
        break;
      case 'success':
        color = Colors.green;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'danger':
        color = Colors.red;
        break;
      case 'info':
        color = Colors.cyan;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        colorType,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}