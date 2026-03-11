import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 通用分页组件
///
/// 提供统一的分页控制界面，包含：
/// - 每页条数选择 (10/20/50/100)
/// - 上一页/下一页按钮
/// - 当前页/总页数显示
///
/// 使用示例：
/// ```dart
/// Pagination(
///   currentPage: _currentPage,
///   pageSize: _pageSize,
///   totalCount: _totalCount,
///   onPageChanged: (page) {
///     setState(() => _currentPage = page);
///     _loadData();
///   },
///   onPageSizeChanged: (size) {
///     setState(() {
///       _pageSize = size;
///       _currentPage = 1;
///     });
///     _loadData();
///   },
/// )
/// ```
class Pagination extends StatelessWidget {
  /// 当前页码 (从1开始)
  final int currentPage;

  /// 每页条数
  final int pageSize;

  /// 总记录数
  final int totalCount;

  /// 页码改变回调
  final void Function(int page) onPageChanged;

  /// 每页条数改变回调
  final void Function(int pageSize) onPageSizeChanged;

  /// 可选的每页条数选项
  final List<int> pageSizeOptions;

  /// 总页数
  int get totalPages => (totalCount / pageSize).ceil();

  /// 是否有上一页
  bool get hasPrevious => currentPage > 1;

  /// 是否有下一页
  bool get hasNext => currentPage * pageSize < totalCount;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 每页行数选择
        Row(
          children: [
            Text('${S.current.pageSize}: '),
            DropdownButton<int>(
              value: pageSize,
              items: pageSizeOptions.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != pageSize) {
                  onPageSizeChanged(value);
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 24),
        // 分页导航
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: hasPrevious ? () => onPageChanged(currentPage - 1) : null,
            ),
            Text('$currentPage / $totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: hasNext ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// 带总数显示的分页组件
///
/// 在分页控件前显示总记录数
class PaginationWithTotal extends StatelessWidget {
  /// 当前页码 (从1开始)
  final int currentPage;

  /// 每页条数
  final int pageSize;

  /// 总记录数
  final int totalCount;

  /// 页码改变回调
  final void Function(int page) onPageChanged;

  /// 每页条数改变回调
  final void Function(int pageSize) onPageSizeChanged;

  /// 可选的每页条数选项
  final List<int> pageSizeOptions;

  const PaginationWithTotal({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${S.current.total}: $totalCount'),
        const SizedBox(width: 16),
        Expanded(
          child: Pagination(
            currentPage: currentPage,
            pageSize: pageSize,
            totalCount: totalCount,
            onPageChanged: onPageChanged,
            onPageSizeChanged: onPageSizeChanged,
            pageSizeOptions: pageSizeOptions,
          ),
        ),
      ],
    );
  }
}