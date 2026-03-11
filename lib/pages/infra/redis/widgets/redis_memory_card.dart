import 'dart:math';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/infra/redis.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// Redis 内存卡片组件
class RedisMemoryCard extends StatelessWidget {
  final RedisMonitorInfo? redisData;

  const RedisMemoryCard({
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

    final usedMemory = info.usedMemoryHuman ?? '0';
    final memoryValue = _parseMemoryValue(usedMemory);
    final totalMemoryValue = _parseMemoryValue(info.maxmemoryHuman ?? '0');

    // 计算内存使用百分比
    double memoryPercent = 0;
    if (totalMemoryValue > 0) {
      memoryPercent = (memoryValue / totalMemoryValue * 100).clamp(0, 100);
    }

    return Column(
      children: [
        // 内存仪表盘
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _GaugePainter(
              value: memoryValue,
              maxValue: totalMemoryValue > 0 ? totalMemoryValue : 100,
              label: usedMemory,
              theme: Theme.of(context),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 内存详细信息
        _buildMemoryDetails(context, info),
      ],
    );
  }

  Widget _buildMemoryDetails(BuildContext context, RedisInfo info) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          S.current.usedMemoryPeak,
          info.usedMemoryPeakHuman ?? '-',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          S.current.memFragmentationRatio,
          info.memFragmentationRatio ?? '-',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          S.current.usedMemoryRss,
          info.usedMemoryRssHuman ?? '-',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          S.current.totalSystemMemory,
          info.totalSystemMemoryHuman ?? '-',
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  double _parseMemoryValue(String memStr) {
    if (memStr.isEmpty) return 0;
    try {
      final match = RegExp(r'^([\d.]+)').firstMatch(memStr);
      return match != null ? double.parse(match.group(1)!) : 0;
    } catch (e) {
      return 0;
    }
  }
}

/// 仪表盘绘制器
class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final String label;
  final ThemeData theme;

  _GaugePainter({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = size.width * 0.3;

    // 绘制背景弧
    final backgroundPaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreeToRad(135),
      _degreeToRad(270),
      false,
      backgroundPaint,
    );

    // 计算进度
    final percent = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final sweepAngle = _degreeToRad(270 * percent);

    // 选择颜色
    Color progressColor;
    if (percent < 0.2) {
      progressColor = Colors.green;
    } else if (percent < 0.8) {
      progressColor = Colors.cyan;
    } else {
      progressColor = Colors.red;
    }

    // 绘制进度弧
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreeToRad(135),
      sweepAngle,
      false,
      progressPaint,
    );

    // 绘制指针
    final pointerAngle = _degreeToRad(135 + 270 * percent);
    final pointerPaint = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pointerLength = radius * 0.7;
    final pointerEnd = Offset(
      center.dx + pointerLength * cos(pointerAngle),
      center.dy + pointerLength * sin(pointerAngle),
    );

    canvas.drawLine(center, pointerEnd, pointerPaint);

    // 绘制中心圆点
    final centerPaint = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);

    // 绘制标签
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.3,
      ),
    );

    // 绘制标题
    final titlePainter = TextPainter(
      text: TextSpan(
        text: S.current.memoryConsumption,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    titlePainter.paint(
      canvas,
      Offset(
        center.dx - titlePainter.width / 2,
        center.dy + radius * 0.3 + textPainter.height + 4,
      ),
    );
  }

  double _degreeToRad(double degree) {
    return degree * 3.14159265359 / 180;
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return value != oldDelegate.value ||
        maxValue != oldDelegate.maxValue ||
        label != oldDelegate.label;
  }
}