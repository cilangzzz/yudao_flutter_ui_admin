import 'package:flutter/material.dart';
import '../../../../models/infra/redis.dart';
import '../../../../i18n/i18n.dart';

/// Redis 信息卡片组件
class RedisInfoCard extends StatelessWidget {
  final RedisMonitorInfo? redisData;

  const RedisInfoCard({
    super.key,
    this.redisData,
  });

  @override
  Widget build(BuildContext context) {
    final info = redisData?.info;
    if (info == null) {
      return Center(
        child: Text(S.current.noData),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final items = _buildInfoItems(info, redisData!.dbSize);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: items.map((item) => _buildInfoItem(context, item)).toList(),
        );
      },
    );
  }

  List<_InfoItem> _buildInfoItems(RedisInfo info, int dbSize) {
    return [
      _InfoItem(
        label: S.current.redisVersionLabel,
        value: info.redisVersion ?? '-',
      ),
      _InfoItem(
        label: S.current.redisMode,
        value: info.redisMode == 'standalone' ? S.current.standalone : S.current.cluster,
      ),
      _InfoItem(
        label: S.current.port,
        value: info.tcpPort ?? '-',
      ),
      _InfoItem(
        label: S.current.connectedClients,
        value: info.connectedClients ?? '-',
      ),
      _InfoItem(
        label: S.current.uptimeInDays,
        value: info.uptimeInDays ?? '-',
      ),
      _InfoItem(
        label: S.current.usedMemory,
        value: info.usedMemoryHuman ?? '-',
      ),
      _InfoItem(
        label: S.current.usedCpu,
        value: _formatCpu(info.usedCpuUserChildren),
      ),
      _InfoItem(
        label: S.current.memoryConfig,
        value: info.maxmemoryHuman ?? '-',
      ),
      _InfoItem(
        label: S.current.aofEnabled,
        value: info.aofEnabled == '0' ? S.current.no : S.current.yes,
      ),
      _InfoItem(
        label: S.current.rdbLastBgsaveStatus,
        value: info.rdbLastBgsaveStatus ?? '-',
      ),
      _InfoItem(
        label: S.current.keyCount,
        value: dbSize.toString(),
      ),
      _InfoItem(
        label: S.current.networkIO,
        value: '${info.instantaneousInputKbps ?? '-'}kps / ${info.instantaneousOutputKbps ?? '-'}kps',
      ),
    ];
  }

  Widget _buildInfoItem(BuildContext context, _InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCpu(String? value) {
    if (value == null) return '-';
    try {
      final cpu = double.parse(value);
      return cpu.toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem({
    required this.label,
    required this.value,
  });
}