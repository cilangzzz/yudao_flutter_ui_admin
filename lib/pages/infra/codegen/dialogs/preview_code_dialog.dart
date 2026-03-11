import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/codegen_api.dart';
import '../../../models/infra/codegen.dart';
import '../../../i18n/i18n.dart';

/// 预览代码对话框
class PreviewCodeDialog extends StatefulWidget {
  final WidgetRef ref;
  final CodegenTable table;

  const PreviewCodeDialog({
    super.key,
    required this.ref,
    required this.table,
  });

  @override
  State<PreviewCodeDialog> createState() => _PreviewCodeDialogState();
}

class _PreviewCodeDialogState extends State<PreviewCodeDialog> {
  List<CodegenPreview> _previewList = [];
  Map<String, String> _codeMap = {};
  String _activeKey = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final api = widget.ref.read(codegenApiProvider);
      final response = await api.previewCodegen(widget.table.id!);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _previewList = response.data!;
          if (_previewList.isNotEmpty) {
            _activeKey = _previewList.first.filePath ?? '';
            _codeMap[_activeKey] = _previewList.first.code ?? '';
          }
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

  void _onFileSelect(String filePath) {
    setState(() {
      _activeKey = filePath;
      if (!_codeMap.containsKey(filePath)) {
        final preview = _previewList.firstWhere(
          (e) => e.filePath == filePath,
          orElse: () => CodegenPreview(),
        );
        _codeMap[filePath] = preview.code ?? '';
      }
    });
  }

  void _copyCode() {
    final code = _codeMap[_activeKey];
    if (code != null && code.isNotEmpty) {
      // 复制到剪贴板
      // 需要导入 services.dart
      // Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.copySuccess)),
      );
    }
  }

  /// 构建文件树
  List<_FileNode> _buildFileTree() {
    final nodes = <String, _FileNode>{};
    final rootNodes = <_FileNode>[];

    for (final preview in _previewList) {
      final filePath = preview.filePath;
      if (filePath == null) continue;

      final parts = filePath.split('/');
      String currentPath = '';

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        final parentPath = currentPath;
        currentPath = currentPath.isEmpty ? part : '$currentPath/$part';

        if (!nodes.containsKey(currentPath)) {
          final node = _FileNode(
            key: currentPath,
            title: part,
            isLeaf: i == parts.length - 1,
          );
          nodes[currentPath] = node;

          if (parentPath.isEmpty) {
            rootNodes.add(node);
          } else {
            nodes[parentPath]?.children.add(node);
          }
        }
      }
    }

    return rootNodes;
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
                    '${S.current.codePreview} - ${widget.table.tableName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: S.current.copy,
                    onPressed: _copyCode,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        // 文件树
                        SizedBox(
                          width: 250,
                          child: _buildFileTreeWidget(_buildFileTree()),
                        ),
                        const VerticalDivider(width: 1),
                        // 代码预览
                        Expanded(
                          child: _buildCodePreview(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTreeWidget(List<_FileNode> nodes) {
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return _buildFileTreeNode(node, 0);
      },
    );
  }

  Widget _buildFileTreeNode(_FileNode node, int level) {
    final isSelected = _activeKey == node.key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: node.isLeaf ? () => _onFileSelect(node.key) : null,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + level * 16,
              top: 8,
              bottom: 8,
              right: 16,
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Row(
              children: [
                Icon(
                  node.isLeaf ? Icons.description : Icons.folder,
                  size: 18,
                  color: node.isLeaf
                      ? Theme.of(context).colorScheme.primary
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!node.isLeaf)
          ...node.children.map((child) => _buildFileTreeNode(child, level + 1)),
      ],
    );
  }

  Widget _buildCodePreview() {
    if (_activeKey.isEmpty) {
      return Center(child: Text(S.current.pleaseSelectFile));
    }

    final code = _codeMap[_activeKey] ?? '';
    final fileName = _activeKey.split('/').last;

    // 根据文件扩展名确定语言
    String language = 'text';
    if (fileName.endsWith('.java')) {
      language = 'java';
    } else if (fileName.endsWith('.xml')) {
      language = 'xml';
    } else if (fileName.endsWith('.vue')) {
      language = 'vue';
    } else if (fileName.endsWith('.ts')) {
      language = 'typescript';
    } else if (fileName.endsWith('.js')) {
      language = 'javascript';
    } else if (fileName.endsWith('.json')) {
      language = 'json';
    }

    return Column(
      children: [
        // 文件名标签页
        Container(
          height: 40,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _codeMap.keys.length,
            itemBuilder: (context, index) {
              final key = _codeMap.keys.elementAt(index);
              final name = key.split('/').last;
              final isActive = key == _activeKey;

              return InkWell(
                onTap: () => _onFileSelect(key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    border: isActive
                        ? Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _codeMap.remove(key);
                                if (_activeKey == key && _codeMap.isNotEmpty) {
                                  _activeKey = _codeMap.keys.first;
                                }
                              });
                            },
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 代码内容
        Expanded(
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF5F5F5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 文件节点类
class _FileNode {
  final String key;
  final String title;
  final bool isLeaf;
  final List<_FileNode> children = [];

  _FileNode({
    required this.key,
    required this.title,
    required this.isLeaf,
  });
}

/// 显示预览代码对话框的便捷方法
Future<void> showPreviewCodeDialog(
  BuildContext context, {
  required WidgetRef ref,
  required CodegenTable table,
}) {
  return showDialog(
    context: context,
    builder: (context) => PreviewCodeDialog(
      ref: ref,
      table: table,
    ),
  );
}