import 'package:flutter/material.dart';

/// 仪表板页面
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Text(
              '仪表板',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '欢迎回来，查看系统概览',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // 统计卡片
            _buildStatCards(context),
            const SizedBox(height: 24),

            // 快捷操作
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // 最近活动
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final stats = [
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
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _StatCard(stat: stat);
          },
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快捷操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  icon: Icons.person_add,
                  label: '添加用户',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.settings,
                  label: '系统设置',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.assessment,
                  label: '数据报表',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.security,
                  label: '权限管理',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近活动',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(activity.user.substring(0, 1)),
                  ),
                  title: Text('${activity.user} ${activity.action}'),
                  subtitle: Text(activity.target),
                  trailing: Text(
                    activity.time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
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

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        stat.value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
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
                            fontSize: 12,
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
        ),
      ),
    );
  }
}

/// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
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