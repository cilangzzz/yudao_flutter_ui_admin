import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/file_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/file_search_form.dart';
import 'widgets/file_action_buttons.dart';
import 'widgets/file_data_table.dart';
import 'dialogs/file_upload_dialog.dart';

/// 文件管理页面
class FilePage extends ConsumerStatefulWidget {
  const FilePage({super.key});

  @override
  ConsumerState<FilePage> createState() => _FilePageState();
}

class _FilePageState extends ConsumerState<FilePage> {
  final _pathController = TextEditingController();
  final _typeController = TextEditingController();
  DateTimeRange? _dateRange;

  List<File> _fileList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadFileList();
  }

  @override
  void dispose() {
    _pathController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _loadFileList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fileApi = ref.read(fileApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_pathController.text.isNotEmpty) 'path': _pathController.text,
        if (_typeController.text.isNotEmpty) 'type': _typeController.text,
        if (_dateRange != null) ...{
          'createTime': [
            _dateRange!.start.toIso8601String().substring(0, 10),
            _dateRange!.end.toIso8601String().substring(0, 10),
          ].join(','),
        },
      };

      final response = await fileApi.getFilePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _fileList = response.data!.list;
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
    _loadFileList();
  }

  void _reset() {
    _pathController.clear();
    _typeController.clear();
    setState(() {
      _dateRange = null;
      _currentPage = 1;
    });
    _loadFileList();
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteFile} "${file.name ?? file.path}" ?'),
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
        final fileApi = ref.read(fileApiProvider);
        final response = await fileApi.deleteFile(file.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadFileList();
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
        final fileApi = ref.read(fileApiProvider);
        final response = await fileApi.deleteFileList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadFileList();
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

  void _uploadFile() {
    showFileUploadDialog(
      context,
      ref: ref,
      onSuccess: _loadFileList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          FileSearchForm(
            pathController: _pathController,
            typeController: _typeController,
            dateRange: _dateRange,
            onDateRangeChanged: (value) => setState(() => _dateRange = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          FileActionButtons(
            onUpload: _uploadFile,
            onDeleteBatch: _selectedIds.isNotEmpty ? _deleteBatch : null,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: FileDataTable(
              fileList: _fileList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              selectedIds: _selectedIds,
              onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
              onReload: _loadFileList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadFileList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadFileList();
              },
              onDelete: _deleteFile,
            ),
          ),
        ],
      ),
    );
  }
}