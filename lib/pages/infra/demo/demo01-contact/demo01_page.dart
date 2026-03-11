import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo01_contact_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo01_contact.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/demo01_search_form.dart';
import 'widgets/demo01_action_buttons.dart';
import 'widgets/demo01_data_table.dart';
import 'dialogs/demo01_form_dialog.dart';

/// 示例联系人管理页面 - Demo01
class Demo01Page extends ConsumerStatefulWidget {
  const Demo01Page({super.key});

  @override
  ConsumerState<Demo01Page> createState() => _Demo01PageState();
}

class _Demo01PageState extends ConsumerState<Demo01Page> {
  final _nameController = TextEditingController();
  int? _selectedSex;
  DateTimeRange? _createTimeRange;

  List<Demo01Contact> _contactList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadContactList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadContactList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contactApi = ref.read(demo01ContactApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedSex != null) 'sex': _selectedSex,
        if (_createTimeRange != null) ...{
          'createTime': [
            _createTimeRange!.start.toIso8601String(),
            _createTimeRange!.end.toIso8601String(),
          ],
        },
      };

      final response = await contactApi.getDemo01ContactPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _contactList = response.data!.list;
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
    _loadContactList();
  }

  void _reset() {
    _nameController.clear();
    setState(() {
      _selectedSex = null;
      _createTimeRange = null;
      _currentPage = 1;
    });
    _loadContactList();
  }

  Future<void> _deleteContact(Demo01Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteItem} "${contact.name}" ?'),
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
        final contactApi = ref.read(demo01ContactApiProvider);
        final response = await contactApi.deleteDemo01Contact(contact.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadContactList();
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
        content: Text('${S.current.confirmDeleteSelected} ${_selectedIds.length} ${S.current.items}'),
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
        final contactApi = ref.read(demo01ContactApiProvider);
        final response = await contactApi.deleteDemo01ContactList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            setState(() => _selectedIds = {});
            _loadContactList();
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

  Future<void> _export() async {
    try {
      final contactApi = ref.read(demo01ContactApiProvider);
      final params = <String, dynamic>{
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedSex != null) 'sex': _selectedSex,
      };
      await contactApi.exportDemo01Contact(params);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.exportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.exportFailed}: $e')),
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
          Demo01SearchForm(
            nameController: _nameController,
            selectedSex: _selectedSex,
            createTimeRange: _createTimeRange,
            onSexChanged: (value) => setState(() => _selectedSex = value),
            onCreateTimeRangeChanged: (value) => setState(() => _createTimeRange = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          Demo01ActionButtons(
            onAdd: () => showDemo01FormDialog(
              context,
              ref: ref,
              onSuccess: _loadContactList,
            ),
            onExport: _export,
            onDeleteBatch: _selectedIds.isNotEmpty ? _deleteBatch : null,
            hasSelection: _selectedIds.isNotEmpty,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: Demo01DataTable(
              contactList: _contactList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadContactList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadContactList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadContactList();
              },
              onEdit: (contact) => showDemo01FormDialog(
                context,
                contact: contact,
                ref: ref,
                onSuccess: _loadContactList,
              ),
              onDelete: _deleteContact,
              selectedIds: _selectedIds,
              onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
            ),
          ),
        ],
      ),
    );
  }
}