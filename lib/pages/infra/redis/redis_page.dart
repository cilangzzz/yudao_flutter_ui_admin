import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/infra/redis_api.dart';
import '../../../models/infra/redis.dart';
import '../../../i18n/i18n.dart';
import 'widgets/redis_info_card.dart';
import 'widgets/redis_memory_card.dart';
import 'widgets/redis_commands_card.dart';

/// Redis 缓存管理页面
class RedisPage extends ConsumerStatefulWidget {
  const RedisPage({super.key});

  @override
  ConsumerState<RedisPage> createState() => _RedisPageState();
}

class _RedisPageState extends ConsumerState<RedisPage> {
  RedisMonitorInfo? _redisData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRedisData();
  }

  Future<void> _loadRedisData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final redisApi = ref.read(redisApiProvider);
      final response = await redisApi.getRedisMonitorInfo();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _redisData = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.current.loadFailed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRedisData,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRedisData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Redis 概览
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storage, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          S.current.redisOverview,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          S.current.redisVersion.replaceAll('%s', _redisData?.info?.redisVersion ?? '-'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RedisInfoCard(redisData: _redisData),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 内存使用和命令统计
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.memory, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      S.current.memoryUsage,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                RedisMemoryCard(redisData: _redisData),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.terminal, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      S.current.commandStats,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                RedisCommandsCard(redisData: _redisData),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.memory, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  S.current.memoryUsage,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            RedisMemoryCard(redisData: _redisData),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.terminal, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  S.current.commandStats,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            RedisCommandsCard(redisData: _redisData),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}