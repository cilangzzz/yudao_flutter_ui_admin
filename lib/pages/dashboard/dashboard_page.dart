import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 仪表板页面
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 模拟加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 模拟数据加载
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.layoutBuilder(
        builder: (context, uiMode) {
          final isMobile = uiMode == UIMode.mobile;
          final isTablet = uiMode == UIMode.tablet;

          // 响应式值
          final pagePadding = ResponsiveValue<double>(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ).of(context);

          final cardPadding = ResponsiveValue<double>(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ).of(context);

          final titleSize = ResponsiveValue<double>(
            mobile: 22.0,
            tablet: 26.0,
            desktop: 28.0,
          ).of(context);

          final spacing = ResponsiveValue<double>(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ).of(context);

          return SingleChildScrollView(
            padding: EdgeInsets.all(pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Text(
                  '仪表板',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '欢迎回来，查看系统概览',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: spacing),

                // 统计卡片
                _isLoading
                    ? _buildShimmerStatCards(context, uiMode)
                    : _buildStatCards(context, uiMode, cardPadding),
                SizedBox(height: spacing),

                // 快捷操作
                _isLoading
                    ? _buildShimmerCard(context, isMobile)
                    : _buildQuickActions(context, uiMode, cardPadding),
                SizedBox(height: spacing),

                // 最近活动
                _isLoading
                    ? _buildShimmerCard(context, isMobile)
                    : _buildRecentActivity(context, uiMode, cardPadding),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建 shimmer 统计卡片
  Widget _buildShimmerStatCards(BuildContext context, UIMode uiMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ResponsiveValue<int>(
          mobile: 1,
          tablet: 2,
          desktop: 4,
        ).fromWidth(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getChildAspectRatio(constraints.maxWidth, crossAxisCount),
          ),
          itemCount: 4,
          itemBuilder: (context, index) => const _ShimmerStatCard(),
        );
      },
    );
  }

  /// 构建 shimmer 卡片占位
  Widget _buildShimmerCard(BuildContext context, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(width: 80, height: 16),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  child: _buildShimmerBox(width: isMobile ? 70 : 90, height: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建 shimmer 盒子
  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, UIMode uiMode, double cardPadding) {
    final stats = const [
      _StatItem(
        title: '用户总数',
        value: '1,234',
        icon: Icons.people,
        color: Colors.blue,
        change: '+12%',
      ),
      _StatItem(
        title: '活跃用户',
        value: '856',
        icon: Icons.trending_up,
        color: Colors.green,
        change: '+8%',
      ),
      _StatItem(
        title: '今日访问',
        value: '2,345',
        icon: Icons.visibility,
        color: Colors.orange,
        change: '+23%',
      ),
      _StatItem(
        title: '系统角色',
        value: '12',
        icon: Icons.admin_panel_settings,
        color: Colors.purple,
        change: '0%',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 DeviceUIMode 工具类的断点
        final crossAxisCount = ResponsiveValue<int>(
          mobile: 1,
          tablet: 2,
          desktop: 4,
        ).fromWidth(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // 动态计算 childAspectRatio 防止溢出
            childAspectRatio: _getChildAspectRatio(constraints.maxWidth, crossAxisCount),
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _StatCard(stat: stat, cardPadding: cardPadding);
          },
        );
      },
    );
  }

  /// 动态计算卡片宽高比，防止高缩放时溢出
  double _getChildAspectRatio(double width, int crossAxisCount) {
    final cardWidth = (width - (crossAxisCount - 1) * 16) / crossAxisCount;
    // 根据卡片宽度动态调整高度
    final cardHeight = cardWidth * 0.42; // 约等于 2.38 的比例
    return cardWidth / cardHeight.clamp(80.0, 120.0);
  }

  Widget _buildQuickActions(BuildContext context, UIMode uiMode, double cardPadding) {
    final isMobile = uiMode == UIMode.mobile;
    final spacing = ResponsiveValue<double>(
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    ).of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快捷操作',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: const [
                _ActionButton(
                  icon: Icons.person_add,
                  label: '添加用户',
                ),
                _ActionButton(
                  icon: Icons.settings,
                  label: '系统设置',
                ),
                _ActionButton(
                  icon: Icons.assessment,
                  label: '数据报表',
                ),
                _ActionButton(
                  icon: Icons.security,
                  label: '权限管理',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, UIMode uiMode, double cardPadding) {
    final activities = const [
      _ActivityItem(
        user: '管理员',
        action: '创建了新用户',
        target: '张三',
        time: '5分钟前',
      ),
      _ActivityItem(
        user: '管理员',
        action: '修改了角色权限',
        target: '编辑角色',
        time: '10分钟前',
      ),
      _ActivityItem(
        user: '系统',
        action: '自动备份完成',
        target: '数据库备份',
        time: '1小时前',
      ),
    ];

    final isMobile = uiMode == UIMode.mobile;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近活动',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityTile(
                  activity: activity,
                  isMobile: isMobile,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer 统计卡片
class _ShimmerStatCard extends StatelessWidget {
  const _ShimmerStatCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标占位
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题占位
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 数值占位
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计项
class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  final _StatItem stat;
  final double cardPadding;

  const _StatCard({
    required this.stat,
    required this.cardPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 根据可用空间动态调整布局
            final isCompact = constraints.maxWidth < 200;

            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isCompact ? 8 : 12),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat.icon,
                    color: stat.color,
                    size: isCompact ? 22 : 28,
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: isCompact ? 12 : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              stat.value,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isCompact ? 18 : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: stat.change.startsWith('+')
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stat.change,
                              style: TextStyle(
                                fontSize: isCompact ? 10 : 12,
                                color: stat.change.startsWith('+')
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// 活动项
class _ActivityItem {
  final String user;
  final String action;
  final String target;
  final String time;

  const _ActivityItem({
    required this.user,
    required this.action,
    required this.target,
    required this.time,
  });
}

/// 活动列表项
class _ActivityTile extends StatelessWidget {
  final _ActivityItem activity;
  final bool isMobile;

  const _ActivityTile({
    required this.activity,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: isMobile ? 32 : 40,
      leading: CircleAvatar(
        radius: isMobile ? 16 : 20,
        child: Text(
          activity.user.substring(0, 1),
          style: TextStyle(fontSize: isMobile ? 12 : 14),
        ),
      ),
      title: Text(
        '${activity.user} ${activity.action}',
        style: TextStyle(fontSize: isMobile ? 13 : 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        activity.target,
        style: TextStyle(fontSize: isMobile ? 11 : 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        activity.time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 10 : 12,
            ),
      ),
    );
  }
}