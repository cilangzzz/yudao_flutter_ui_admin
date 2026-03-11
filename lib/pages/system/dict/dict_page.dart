import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_type_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_data_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_type.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_data.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_param.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'widgets/dict_type_search_form.dart';
import 'widgets/dict_type_action_buttons.dart';
import 'widgets/dict_type_table.dart';
import 'widgets/dict_data_search_form.dart';
import 'widgets/dict_data_action_buttons.dart';
import 'widgets/dict_data_table.dart';
import 'dialogs/dict_type_form_dialog.dart';
import 'dialogs/dict_data_form_dialog.dart';

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
    setState(() => _typeCurrentPage = 1);
    _loadDictTypeList();
  }

  void _resetDictTypeSearch() {
    _typeSearchController.clear();
    setState(() {
      _typeStatusFilter = null;
      _typeCurrentPage = 1;
    });
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
    setState(() => _dataCurrentPage = 1);
    _loadDictDataList();
  }

  void _resetDictDataSearch() {
    _dataSearchController.clear();
    setState(() {
      _dataStatusFilter = null;
      _dataCurrentPage = 1;
    });
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

  // ==================== UI 构建方法 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.layoutBuilder(
        builder: (context, mode) {
          if (mode == UIMode.mobile) {
            return _buildMobileLayout(context);
          }
          return _buildDesktopLayout(context);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final screenWidth = DeviceUIMode.widthOf(context);
    // 响应式左侧面板宽度，防止溢出
    final leftPanelWidth = screenWidth < 1200
        ? screenWidth * 0.45
        : screenWidth * 0.4;

    return Row(
      children: [
        // 左侧字典类型列表
        SizedBox(
          width: leftPanelWidth.clamp(300.0, 600.0),
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 搜索栏
                DictTypeSearchForm(
                  searchController: _typeSearchController,
                  selectedStatus: _typeStatusFilter,
                  onStatusChanged: (value) => setState(() => _typeStatusFilter = value),
                  onSearch: _searchDictType,
                  onReset: _resetDictTypeSearch,
                ),
                const Divider(height: 1),
                // 工具栏
                DictTypeActionButtons(
                  onAdd: () => showDictTypeFormDialog(
                    context,
                    ref: ref,
                    onSuccess: _loadDictTypeList,
                  ),
                  onDeleteSelected: _deleteSelectedDictTypes,
                  hasSelection: _selectedTypeIds.isNotEmpty,
                  totalCount: _typeTotalCount,
                ),
                const Divider(height: 1),
                // 数据表格
                Expanded(
                  child: DictTypeTable(
                    dictTypeList: _dictTypeList,
                    selectedIds: _selectedTypeIds,
                    totalCount: _typeTotalCount,
                    currentPage: _typeCurrentPage,
                    pageSize: _typePageSize,
                    isLoading: _typeIsLoading,
                    error: _typeError,
                    onReload: _loadDictTypeList,
                    onPageSizeChanged: (value) {
                      setState(() {
                        _typePageSize = value;
                        _typeCurrentPage = 1;
                      });
                      _loadDictTypeList();
                    },
                    onPageChanged: (page) {
                      setState(() => _typeCurrentPage = page);
                      _loadDictTypeList();
                    },
                    onSelectionChanged: (ids) => setState(() => _selectedTypeIds = ids),
                    onEdit: (dictType) => showDictTypeFormDialog(
                      context,
                      dictType: dictType,
                      ref: ref,
                      onSuccess: _loadDictTypeList,
                    ),
                    onDelete: _deleteDictType,
                    onSelect: _handleDictTypeSelect,
                  ),
                ),
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
                DictDataSearchForm(
                  selectedDictType: _selectedDictType,
                  searchController: _dataSearchController,
                  selectedStatus: _dataStatusFilter,
                  onStatusChanged: (value) => setState(() => _dataStatusFilter = value),
                  onSearch: _searchDictData,
                  onReset: _resetDictDataSearch,
                ),
                const Divider(height: 1),
                // 工具栏
                DictDataActionButtons(
                  onAdd: () => showDictDataFormDialog(
                    context,
                    dictType: _selectedDictType,
                    ref: ref,
                    onSuccess: _loadDictDataList,
                  ),
                  onDeleteSelected: _deleteSelectedDictData,
                  hasSelection: _selectedDataIds.isNotEmpty,
                  hasDictType: _selectedDictType != null,
                  totalCount: _dataTotalCount,
                ),
                const Divider(height: 1),
                // 数据表格
                Expanded(
                  child: DictDataTable(
                    dictDataList: _dictDataList,
                    selectedIds: _selectedDataIds,
                    totalCount: _dataTotalCount,
                    currentPage: _dataCurrentPage,
                    pageSize: _dataPageSize,
                    isLoading: _dataIsLoading,
                    error: _dataError,
                    selectedDictType: _selectedDictType,
                    onReload: _loadDictDataList,
                    onPageSizeChanged: (value) {
                      setState(() {
                        _dataPageSize = value;
                        _dataCurrentPage = 1;
                      });
                      _loadDictDataList();
                    },
                    onPageChanged: (page) {
                      setState(() => _dataCurrentPage = page);
                      _loadDictDataList();
                    },
                    onSelectionChanged: (ids) => setState(() => _selectedDataIds = ids),
                    onEdit: (dictData) => showDictDataFormDialog(
                      context,
                      dictData: dictData,
                      dictType: _selectedDictType,
                      ref: ref,
                      onSuccess: _loadDictDataList,
                    ),
                    onDelete: _deleteDictData,
                  ),
                ),
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
          constraints: const BoxConstraints(minHeight: 60, maxHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text('${S.current.dictType}: '),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDictType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: _dictTypeList.map((type) {
                    return DropdownMenuItem(
                      value: type.type,
                      child: Text(
                        type.name,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              const SizedBox(width: 8),
              // 添加字典类型按钮
              IconButton(
                onPressed: () => showDictTypeFormDialog(
                  context,
                  ref: ref,
                  onSuccess: _loadDictTypeList,
                ),
                icon: const Icon(Icons.add),
                tooltip: S.current.addType,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 字典数据列表
        Expanded(
          child: DictDataTable(
            dictDataList: _dictDataList,
            selectedIds: _selectedDataIds,
            totalCount: _dataTotalCount,
            currentPage: _dataCurrentPage,
            pageSize: _dataPageSize,
            isLoading: _dataIsLoading,
            error: _dataError,
            selectedDictType: _selectedDictType,
            onReload: _loadDictDataList,
            onPageSizeChanged: (value) {
              setState(() {
                _dataPageSize = value;
                _dataCurrentPage = 1;
              });
              _loadDictDataList();
            },
            onPageChanged: (page) {
              setState(() => _dataCurrentPage = page);
              _loadDictDataList();
            },
            onSelectionChanged: (ids) => setState(() => _selectedDataIds = ids),
            onEdit: (dictData) => showDictDataFormDialog(
              context,
              dictData: dictData,
              dictType: _selectedDictType,
              ref: ref,
              onSuccess: _loadDictDataList,
            ),
            onDelete: _deleteDictData,
          ),
        ),
      ],
    );
  }
}