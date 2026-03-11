import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/infra/redis.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// Redis 命令统计卡片组件
class RedisCommandsCard extends StatelessWidget {
  final RedisMonitorInfo? redisData;

  const RedisCommandsCard({
    super.key,
    this.redisData,
  });

  @override
  Widget build(BuildContext context) {
    final commandStats = redisData?.commandStats ?? [];

    if (commandStats.isEmpty) {
      return Center(
        child: Text(S.current.noData),
      );
    }

    // 按调用次数排序，取前10个
    final sortedStats = List<RedisCommandStats>.from(commandStats)
      ..sort((a, b) => b.calls.compareTo(a.calls));
    final topStats = sortedStats.take(10).toList();

    // 计算总调用次数
    final totalCalls = commandStats.fold<int>(0, (sum, stat) => sum + stat.calls);

    return Column(
      children: [
        // 总调用次数
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                S.current.totalCommands.replaceAll('%s', totalCalls.toString()),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 命令统计条形图
        ...topStats.map((stat) => _buildCommandBar(context, stat, totalCalls)),
      ],
    );
  }

  Widget _buildCommandBar(BuildContext context, RedisCommandStats stat, int totalCalls) {
    final percent = totalCalls > 0 ? stat.calls / totalCalls : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.command.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                stat.calls.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // 背景条
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // 进度条
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 8,
                    width: constraints.maxWidth * percent,
                    decoration: BoxDecoration(
                      color: _getCommandColor(stat.command),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCommandColor(String command) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange,
    ];

    final index = command.hashCode % colors.length;
    return colors[index.abs()];
  }
}