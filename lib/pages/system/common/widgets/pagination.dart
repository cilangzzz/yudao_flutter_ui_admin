import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

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

  /// 是否使用紧凑模式（移动端）
  final bool compact;

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
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final useCompactMode = compact || isMobile;

    if (useCompactMode) {
      return _buildCompactPagination(context);
    }

    return _buildFullPagination(context);
  }

  /// 构建完整分页（桌面端）
  Widget _buildFullPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 每页行数选择
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${S.current.pageSize}: ',
                overflow: TextOverflow.ellipsis,
              ),
              Flexible(
                child: DropdownButton<int>(
                  value: pageSize,
                  isDense: true,
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
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // 分页导航
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                onPressed: hasPrevious ? () => onPageChanged(currentPage - 1) : null,
              ),
              Flexible(
                child: Text(
                  '$currentPage / $totalPages',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                onPressed: hasNext ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建紧凑分页（移动端）
  Widget _buildCompactPagination(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 紧凑的分页导航
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: hasPrevious ? () => onPageChanged(currentPage - 1) : null,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.3,
                  ),
                  child: Text(
                    '$currentPage/$totalPages',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: hasNext ? () => onPageChanged(currentPage + 1) : null,
                ),
              ],
            ),
            // 紧凑的每页条数选择
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${S.current.pageSize}:',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  value: pageSize,
                  isDense: true,
                  style: const TextStyle(fontSize: 12),
                  underline: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
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
          ],
        );
      },
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

  /// 是否使用紧凑模式（移动端）
  final bool compact;

  const PaginationWithTotal({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final useCompactMode = compact || isMobile;

    if (useCompactMode) {
      return _buildCompactLayout(context);
    }

    return _buildFullLayout(context);
  }

  /// 构建完整布局（桌面端）
  Widget _buildFullLayout(BuildContext context) {
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
            compact: compact,
          ),
        ),
      ],
    );
  }

  /// 构建紧凑布局（移动端）
  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 总数显示
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${S.current.total}: $totalCount',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 分页控件
        Pagination(
          currentPage: currentPage,
          pageSize: pageSize,
          totalCount: totalCount,
          onPageChanged: onPageChanged,
          onPageSizeChanged: onPageSizeChanged,
          pageSizeOptions: pageSizeOptions,
          compact: true,
        ),
      ],
    );
  }
}

/// 响应式分页包装器
///
/// 根据屏幕宽度自动选择紧凑或完整模式
class ResponsivePagination extends StatelessWidget {
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

  /// 是否显示总数
  final bool showTotal;

  const ResponsivePagination({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showTotal) {
      return PaginationWithTotal(
        currentPage: currentPage,
        pageSize: pageSize,
        totalCount: totalCount,
        onPageChanged: onPageChanged,
        onPageSizeChanged: onPageSizeChanged,
        pageSizeOptions: pageSizeOptions,
      );
    }

    return Pagination(
      currentPage: currentPage,
      pageSize: pageSize,
      totalCount: totalCount,
      onPageChanged: onPageChanged,
      onPageSizeChanged: onPageSizeChanged,
      pageSizeOptions: pageSizeOptions,
    );
  }
}