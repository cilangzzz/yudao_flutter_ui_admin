/// Redis 信息模型
class RedisInfo {
  final String? ioThreadedReadsProcessed;
  final String? trackingClients;
  final String? uptimeInSeconds;
  final String? clusterConnections;
  final String? currentCowSize;
  final String? maxmemoryHuman;
  final String? aofLastCowSize;
  final String? masterReplid2;
  final String? memReplicationBacklog;
  final String? aofRewriteScheduled;
  final String? totalNetInputBytes;
  final String? rssOverheadRatio;
  final String? hz;
  final String? currentCowSizeAge;
  final String? redisBuildId;
  final String? aofLastBgrewriteStatus;
  final String? multiplexingApi;
  final String? clientRecentMaxOutputBuffer;
  final String? allocatorResident;
  final String? memFragmentationBytes;
  final String? aofCurrentSize;
  final String? replBacklogFirstByteOffset;
  final String? trackingTotalPrefixes;
  final String? redisMode;
  final String? redisGitDirty;
  final String? aofDelayedFsync;
  final String? allocatorRssBytes;
  final String? replBacklogHistlen;
  final String? ioThreadsActive;
  final String? rssOverheadBytes;
  final String? totalSystemMemory;
  final String? loading;
  final String? evictedKeys;
  final String? maxclients;
  final String? clusterEnabled;
  final String? redisVersion;
  final String? replBacklogActive;
  final String? memAofBuffer;
  final String? allocatorFragBytes;
  final String? ioThreadedWritesProcessed;
  final String? instantaneousOpsPerSec;
  final String? usedMemoryHuman;
  final String? totalErrorReplies;
  final String? role;
  final String? maxmemory;
  final String? usedMemoryLua;
  final String? rdbCurrentBgsaveTimeSec;
  final String? usedMemoryStartup;
  final String? usedCpuSysMainThread;
  final String? lazyfreePendingObjects;
  final String? aofPendingBioFsync;
  final String? usedMemoryDatasetPerc;
  final String? allocatorFragRatio;
  final String? archBits;
  final String? usedCpuUserMainThread;
  final String? memClientsNormal;
  final String? expiredTimeCapReachedCount;
  final String? unexpectedErrorReplies;
  final String? memFragmentationRatio;
  final String? aofLastRewriteTimeSec;
  final String? masterReplid;
  final String? aofRewriteInProgress;
  final String? lruClock;
  final String? maxmemoryPolicy;
  final String? runId;
  final String? latestForkUsec;
  final String? trackingTotalItems;
  final String? totalCommandsProcessed;
  final String? expiredKeys;
  final String? usedMemory;
  final String? moduleForkInProgress;
  final String? aofBufferLength;
  final String? dumpPayloadSanitizations;
  final String? memClientsSlaves;
  final String? keyspaceMisses;
  final String? serverTimeUsec;
  final String? executable;
  final String? lazyfreedObjects;
  final String? db0;
  final String? usedMemoryPeakHuman;
  final String? keyspaceHits;
  final String? rdbLastCowSize;
  final String? aofPendingRewrite;
  final String? usedMemoryOverhead;
  final String? activeDefragHits;
  final String? tcpPort;
  final String? uptimeInDays;
  final String? usedMemoryPeakPerc;
  final String? currentSaveKeysProcessed;
  final String? blockedClients;
  final String? totalReadsProcessed;
  final String? expireCycleCpuMilliseconds;
  final String? syncPartialErr;
  final String? usedMemoryScriptsHuman;
  final String? aofCurrentRewriteTimeSec;
  final String? aofEnabled;
  final String? processSupervised;
  final String? masterReplOffset;
  final String? usedMemoryDataset;
  final String? usedCpuUser;
  final String? rdbLastBgsaveStatus;
  final String? trackingTotalKeys;
  final String? atomicvarApi;
  final String? allocatorRssRatio;
  final String? clientRecentMaxInputBuffer;
  final String? clientsInTimeoutTable;
  final String? aofLastWriteStatus;
  final String? memAllocator;
  final String? usedMemoryScripts;
  final String? usedMemoryPeak;
  final String? processId;
  final String? masterFailoverState;
  final String? usedCpuSys;
  final String? replBacklogSize;
  final String? connectedSlaves;
  final String? currentSaveKeysTotal;
  final String? gccVersion;
  final String? totalSystemMemoryHuman;
  final String? syncFull;
  final String? connectedClients;
  final String? moduleForkLastCowSize;
  final String? totalWritesProcessed;
  final String? allocatorActive;
  final String? totalNetOutputBytes;
  final String? pubsubChannels;
  final String? currentForkPerc;
  final String? activeDefragKeyHits;
  final String? rdbChangesSinceLastSave;
  final String? instantaneousInputKbps;
  final String? usedMemoryRssHuman;
  final String? configuredHz;
  final String? expiredStalePerc;
  final String? activeDefragMisses;
  final String? usedCpuSysChildren;
  final String? numberOfCachedScripts;
  final String? syncPartialOk;
  final String? usedMemoryLuaHuman;
  final String? rdbLastSaveTime;
  final String? pubsubPatterns;
  final String? slaveExpiresTrackedKeys;
  final String? redisGitSha1;
  final String? usedMemoryRss;
  final String? rdbLastBgsaveTimeSec;
  final String? os;
  final String? memNotCountedForEvict;
  final String? activeDefragRunning;
  final String? rejectedConnections;
  final String? aofRewriteBufferLength;
  final String? totalForks;
  final String? activeDefragKeyMisses;
  final String? allocatorAllocated;
  final String? aofBaseSize;
  final String? instantaneousOutputKbps;
  final String? secondReplOffset;
  final String? rdbBgsaveInProgress;
  final String? usedCpuUserChildren;
  final String? totalConnectionsReceived;
  final String? migrateCachedSockets;

  RedisInfo({
    this.ioThreadedReadsProcessed,
    this.trackingClients,
    this.uptimeInSeconds,
    this.clusterConnections,
    this.currentCowSize,
    this.maxmemoryHuman,
    this.aofLastCowSize,
    this.masterReplid2,
    this.memReplicationBacklog,
    this.aofRewriteScheduled,
    this.totalNetInputBytes,
    this.rssOverheadRatio,
    this.hz,
    this.currentCowSizeAge,
    this.redisBuildId,
    this.aofLastBgrewriteStatus,
    this.multiplexingApi,
    this.clientRecentMaxOutputBuffer,
    this.allocatorResident,
    this.memFragmentationBytes,
    this.aofCurrentSize,
    this.replBacklogFirstByteOffset,
    this.trackingTotalPrefixes,
    this.redisMode,
    this.redisGitDirty,
    this.aofDelayedFsync,
    this.allocatorRssBytes,
    this.replBacklogHistlen,
    this.ioThreadsActive,
    this.rssOverheadBytes,
    this.totalSystemMemory,
    this.loading,
    this.evictedKeys,
    this.maxclients,
    this.clusterEnabled,
    this.redisVersion,
    this.replBacklogActive,
    this.memAofBuffer,
    this.allocatorFragBytes,
    this.ioThreadedWritesProcessed,
    this.instantaneousOpsPerSec,
    this.usedMemoryHuman,
    this.totalErrorReplies,
    this.role,
    this.maxmemory,
    this.usedMemoryLua,
    this.rdbCurrentBgsaveTimeSec,
    this.usedMemoryStartup,
    this.usedCpuSysMainThread,
    this.lazyfreePendingObjects,
    this.aofPendingBioFsync,
    this.usedMemoryDatasetPerc,
    this.allocatorFragRatio,
    this.archBits,
    this.usedCpuUserMainThread,
    this.memClientsNormal,
    this.expiredTimeCapReachedCount,
    this.unexpectedErrorReplies,
    this.memFragmentationRatio,
    this.aofLastRewriteTimeSec,
    this.masterReplid,
    this.aofRewriteInProgress,
    this.lruClock,
    this.maxmemoryPolicy,
    this.runId,
    this.latestForkUsec,
    this.trackingTotalItems,
    this.totalCommandsProcessed,
    this.expiredKeys,
    this.usedMemory,
    this.moduleForkInProgress,
    this.aofBufferLength,
    this.dumpPayloadSanitizations,
    this.memClientsSlaves,
    this.keyspaceMisses,
    this.serverTimeUsec,
    this.executable,
    this.lazyfreedObjects,
    this.db0,
    this.usedMemoryPeakHuman,
    this.keyspaceHits,
    this.rdbLastCowSize,
    this.aofPendingRewrite,
    this.usedMemoryOverhead,
    this.activeDefragHits,
    this.tcpPort,
    this.uptimeInDays,
    this.usedMemoryPeakPerc,
    this.currentSaveKeysProcessed,
    this.blockedClients,
    this.totalReadsProcessed,
    this.expireCycleCpuMilliseconds,
    this.syncPartialErr,
    this.usedMemoryScriptsHuman,
    this.aofCurrentRewriteTimeSec,
    this.aofEnabled,
    this.processSupervised,
    this.masterReplOffset,
    this.usedMemoryDataset,
    this.usedCpuUser,
    this.rdbLastBgsaveStatus,
    this.trackingTotalKeys,
    this.atomicvarApi,
    this.allocatorRssRatio,
    this.clientRecentMaxInputBuffer,
    this.clientsInTimeoutTable,
    this.aofLastWriteStatus,
    this.memAllocator,
    this.usedMemoryScripts,
    this.usedMemoryPeak,
    this.processId,
    this.masterFailoverState,
    this.usedCpuSys,
    this.replBacklogSize,
    this.connectedSlaves,
    this.currentSaveKeysTotal,
    this.gccVersion,
    this.totalSystemMemoryHuman,
    this.syncFull,
    this.connectedClients,
    this.moduleForkLastCowSize,
    this.totalWritesProcessed,
    this.allocatorActive,
    this.totalNetOutputBytes,
    this.pubsubChannels,
    this.currentForkPerc,
    this.activeDefragKeyHits,
    this.rdbChangesSinceLastSave,
    this.instantaneousInputKbps,
    this.usedMemoryRssHuman,
    this.configuredHz,
    this.expiredStalePerc,
    this.activeDefragMisses,
    this.usedCpuSysChildren,
    this.numberOfCachedScripts,
    this.syncPartialOk,
    this.usedMemoryLuaHuman,
    this.rdbLastSaveTime,
    this.pubsubPatterns,
    this.slaveExpiresTrackedKeys,
    this.redisGitSha1,
    this.usedMemoryRss,
    this.rdbLastBgsaveTimeSec,
    this.os,
    this.memNotCountedForEvict,
    this.activeDefragRunning,
    this.rejectedConnections,
    this.aofRewriteBufferLength,
    this.totalForks,
    this.activeDefragKeyMisses,
    this.allocatorAllocated,
    this.aofBaseSize,
    this.instantaneousOutputKbps,
    this.secondReplOffset,
    this.rdbBgsaveInProgress,
    this.usedCpuUserChildren,
    this.totalConnectionsReceived,
    this.migrateCachedSockets,
  });

  factory RedisInfo.fromJson(Map<String, dynamic> json) {
    return RedisInfo(
      ioThreadedReadsProcessed: json['io_threaded_reads_processed']?.toString(),
      trackingClients: json['tracking_clients']?.toString(),
      uptimeInSeconds: json['uptime_in_seconds']?.toString(),
      clusterConnections: json['cluster_connections']?.toString(),
      currentCowSize: json['current_cow_size']?.toString(),
      maxmemoryHuman: json['maxmemory_human']?.toString(),
      aofLastCowSize: json['aof_last_cow_size']?.toString(),
      masterReplid2: json['master_replid2']?.toString(),
      memReplicationBacklog: json['mem_replication_backlog']?.toString(),
      aofRewriteScheduled: json['aof_rewrite_scheduled']?.toString(),
      totalNetInputBytes: json['total_net_input_bytes']?.toString(),
      rssOverheadRatio: json['rss_overhead_ratio']?.toString(),
      hz: json['hz']?.toString(),
      currentCowSizeAge: json['current_cow_size_age']?.toString(),
      redisBuildId: json['redis_build_id']?.toString(),
      aofLastBgrewriteStatus: json['aof_last_bgrewrite_status']?.toString(),
      multiplexingApi: json['multiplexing_api']?.toString(),
      clientRecentMaxOutputBuffer: json['client_recent_max_output_buffer']?.toString(),
      allocatorResident: json['allocator_resident']?.toString(),
      memFragmentationBytes: json['mem_fragmentation_bytes']?.toString(),
      aofCurrentSize: json['aof_current_size']?.toString(),
      replBacklogFirstByteOffset: json['repl_backlog_first_byte_offset']?.toString(),
      trackingTotalPrefixes: json['tracking_total_prefixes']?.toString(),
      redisMode: json['redis_mode']?.toString(),
      redisGitDirty: json['redis_git_dirty']?.toString(),
      aofDelayedFsync: json['aof_delayed_fsync']?.toString(),
      allocatorRssBytes: json['allocator_rss_bytes']?.toString(),
      replBacklogHistlen: json['repl_backlog_histlen']?.toString(),
      ioThreadsActive: json['io_threads_active']?.toString(),
      rssOverheadBytes: json['rss_overhead_bytes']?.toString(),
      totalSystemMemory: json['total_system_memory']?.toString(),
      loading: json['loading']?.toString(),
      evictedKeys: json['evicted_keys']?.toString(),
      maxclients: json['maxclients']?.toString(),
      clusterEnabled: json['cluster_enabled']?.toString(),
      redisVersion: json['redis_version']?.toString(),
      replBacklogActive: json['repl_backlog_active']?.toString(),
      memAofBuffer: json['mem_aof_buffer']?.toString(),
      allocatorFragBytes: json['allocator_frag_bytes']?.toString(),
      ioThreadedWritesProcessed: json['io_threaded_writes_processed']?.toString(),
      instantaneousOpsPerSec: json['instantaneous_ops_per_sec']?.toString(),
      usedMemoryHuman: json['used_memory_human']?.toString(),
      totalErrorReplies: json['total_error_replies']?.toString(),
      role: json['role']?.toString(),
      maxmemory: json['maxmemory']?.toString(),
      usedMemoryLua: json['used_memory_lua']?.toString(),
      rdbCurrentBgsaveTimeSec: json['rdb_current_bgsave_time_sec']?.toString(),
      usedMemoryStartup: json['used_memory_startup']?.toString(),
      usedCpuSysMainThread: json['used_cpu_sys_main_thread']?.toString(),
      lazyfreePendingObjects: json['lazyfree_pending_objects']?.toString(),
      aofPendingBioFsync: json['aof_pending_bio_fsync']?.toString(),
      usedMemoryDatasetPerc: json['used_memory_dataset_perc']?.toString(),
      allocatorFragRatio: json['allocator_frag_ratio']?.toString(),
      archBits: json['arch_bits']?.toString(),
      usedCpuUserMainThread: json['used_cpu_user_main_thread']?.toString(),
      memClientsNormal: json['mem_clients_normal']?.toString(),
      expiredTimeCapReachedCount: json['expired_time_cap_reached_count']?.toString(),
      unexpectedErrorReplies: json['unexpected_error_replies']?.toString(),
      memFragmentationRatio: json['mem_fragmentation_ratio']?.toString(),
      aofLastRewriteTimeSec: json['aof_last_rewrite_time_sec']?.toString(),
      masterReplid: json['master_replid']?.toString(),
      aofRewriteInProgress: json['aof_rewrite_in_progress']?.toString(),
      lruClock: json['lru_clock']?.toString(),
      maxmemoryPolicy: json['maxmemory_policy']?.toString(),
      runId: json['run_id']?.toString(),
      latestForkUsec: json['latest_fork_usec']?.toString(),
      trackingTotalItems: json['tracking_total_items']?.toString(),
      totalCommandsProcessed: json['total_commands_processed']?.toString(),
      expiredKeys: json['expired_keys']?.toString(),
      usedMemory: json['used_memory']?.toString(),
      moduleForkInProgress: json['module_fork_in_progress']?.toString(),
      aofBufferLength: json['aof_buffer_length']?.toString(),
      dumpPayloadSanitizations: json['dump_payload_sanitizations']?.toString(),
      memClientsSlaves: json['mem_clients_slaves']?.toString(),
      keyspaceMisses: json['keyspace_misses']?.toString(),
      serverTimeUsec: json['server_time_usec']?.toString(),
      executable: json['executable']?.toString(),
      lazyfreedObjects: json['lazyfreed_objects']?.toString(),
      db0: json['db0']?.toString(),
      usedMemoryPeakHuman: json['used_memory_peak_human']?.toString(),
      keyspaceHits: json['keyspace_hits']?.toString(),
      rdbLastCowSize: json['rdb_last_cow_size']?.toString(),
      aofPendingRewrite: json['aof_pending_rewrite']?.toString(),
      usedMemoryOverhead: json['used_memory_overhead']?.toString(),
      activeDefragHits: json['active_defrag_hits']?.toString(),
      tcpPort: json['tcp_port']?.toString(),
      uptimeInDays: json['uptime_in_days']?.toString(),
      usedMemoryPeakPerc: json['used_memory_peak_perc']?.toString(),
      currentSaveKeysProcessed: json['current_save_keys_processed']?.toString(),
      blockedClients: json['blocked_clients']?.toString(),
      totalReadsProcessed: json['total_reads_processed']?.toString(),
      expireCycleCpuMilliseconds: json['expire_cycle_cpu_milliseconds']?.toString(),
      syncPartialErr: json['sync_partial_err']?.toString(),
      usedMemoryScriptsHuman: json['used_memory_scripts_human']?.toString(),
      aofCurrentRewriteTimeSec: json['aof_current_rewrite_time_sec']?.toString(),
      aofEnabled: json['aof_enabled']?.toString(),
      processSupervised: json['process_supervised']?.toString(),
      masterReplOffset: json['master_repl_offset']?.toString(),
      usedMemoryDataset: json['used_memory_dataset']?.toString(),
      usedCpuUser: json['used_cpu_user']?.toString(),
      rdbLastBgsaveStatus: json['rdb_last_bgsave_status']?.toString(),
      trackingTotalKeys: json['tracking_total_keys']?.toString(),
      atomicvarApi: json['atomicvar_api']?.toString(),
      allocatorRssRatio: json['allocator_rss_ratio']?.toString(),
      clientRecentMaxInputBuffer: json['client_recent_max_input_buffer']?.toString(),
      clientsInTimeoutTable: json['clients_in_timeout_table']?.toString(),
      aofLastWriteStatus: json['aof_last_write_status']?.toString(),
      memAllocator: json['mem_allocator']?.toString(),
      usedMemoryScripts: json['used_memory_scripts']?.toString(),
      usedMemoryPeak: json['used_memory_peak']?.toString(),
      processId: json['process_id']?.toString(),
      masterFailoverState: json['master_failover_state']?.toString(),
      usedCpuSys: json['used_cpu_sys']?.toString(),
      replBacklogSize: json['repl_backlog_size']?.toString(),
      connectedSlaves: json['connected_slaves']?.toString(),
      currentSaveKeysTotal: json['current_save_keys_total']?.toString(),
      gccVersion: json['gcc_version']?.toString(),
      totalSystemMemoryHuman: json['total_system_memory_human']?.toString(),
      syncFull: json['sync_full']?.toString(),
      connectedClients: json['connected_clients']?.toString(),
      moduleForkLastCowSize: json['module_fork_last_cow_size']?.toString(),
      totalWritesProcessed: json['total_writes_processed']?.toString(),
      allocatorActive: json['allocator_active']?.toString(),
      totalNetOutputBytes: json['total_net_output_bytes']?.toString(),
      pubsubChannels: json['pubsub_channels']?.toString(),
      currentForkPerc: json['current_fork_perc']?.toString(),
      activeDefragKeyHits: json['active_defrag_key_hits']?.toString(),
      rdbChangesSinceLastSave: json['rdb_changes_since_last_save']?.toString(),
      instantaneousInputKbps: json['instantaneous_input_kbps']?.toString(),
      usedMemoryRssHuman: json['used_memory_rss_human']?.toString(),
      configuredHz: json['configured_hz']?.toString(),
      expiredStalePerc: json['expired_stale_perc']?.toString(),
      activeDefragMisses: json['active_defrag_misses']?.toString(),
      usedCpuSysChildren: json['used_cpu_sys_children']?.toString(),
      numberOfCachedScripts: json['number_of_cached_scripts']?.toString(),
      syncPartialOk: json['sync_partial_ok']?.toString(),
      usedMemoryLuaHuman: json['used_memory_lua_human']?.toString(),
      rdbLastSaveTime: json['rdb_last_save_time']?.toString(),
      pubsubPatterns: json['pubsub_patterns']?.toString(),
      slaveExpiresTrackedKeys: json['slave_expires_tracked_keys']?.toString(),
      redisGitSha1: json['redis_git_sha1']?.toString(),
      usedMemoryRss: json['used_memory_rss']?.toString(),
      rdbLastBgsaveTimeSec: json['rdb_last_bgsave_time_sec']?.toString(),
      os: json['os']?.toString(),
      memNotCountedForEvict: json['mem_not_counted_for_evict']?.toString(),
      activeDefragRunning: json['active_defrag_running']?.toString(),
      rejectedConnections: json['rejected_connections']?.toString(),
      aofRewriteBufferLength: json['aof_rewrite_buffer_length']?.toString(),
      totalForks: json['total_forks']?.toString(),
      activeDefragKeyMisses: json['active_defrag_key_misses']?.toString(),
      allocatorAllocated: json['allocator_allocated']?.toString(),
      aofBaseSize: json['aof_base_size']?.toString(),
      instantaneousOutputKbps: json['instantaneous_output_kbps']?.toString(),
      secondReplOffset: json['second_repl_offset']?.toString(),
      rdbBgsaveInProgress: json['rdb_bgsave_in_progress']?.toString(),
      usedCpuUserChildren: json['used_cpu_user_children']?.toString(),
      totalConnectionsReceived: json['total_connections_received']?.toString(),
      migrateCachedSockets: json['migrate_cached_sockets']?.toString(),
    );
  }
}

/// Redis 命令统计
class RedisCommandStats {
  final String command;
  final int calls;
  final int usec;

  RedisCommandStats({
    required this.command,
    required this.calls,
    required this.usec,
  });

  factory RedisCommandStats.fromJson(Map<String, dynamic> json) {
    return RedisCommandStats(
      command: json['command']?.toString() ?? '',
      calls: json['calls'] is int ? json['calls'] : int.tryParse(json['calls']?.toString() ?? '') ?? 0,
      usec: json['usec'] is int ? json['usec'] : int.tryParse(json['usec']?.toString() ?? '') ?? 0,
    );
  }
}

/// Redis 监控信息
class RedisMonitorInfo {
  final RedisInfo? info;
  final int dbSize;
  final List<RedisCommandStats> commandStats;

  RedisMonitorInfo({
    this.info,
    this.dbSize = 0,
    this.commandStats = const [],
  });

  factory RedisMonitorInfo.fromJson(Map<String, dynamic> json) {
    return RedisMonitorInfo(
      info: json['info'] != null ? RedisInfo.fromJson(json['info'] as Map<String, dynamic>) : null,
      dbSize: json['dbSize'] is int ? json['dbSize'] : int.tryParse(json['dbSize']?.toString() ?? '') ?? 0,
      commandStats: json['commandStats'] != null
          ? (json['commandStats'] as List<dynamic>)
              .map((e) => RedisCommandStats.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}