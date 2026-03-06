import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 字典数据项
class DictData {
  final String value;
  final String label;
  final int sort;
  final String? colorType;

  const DictData({
    required this.value,
    required this.label,
    this.sort = 0,
    this.colorType,
  });

  factory DictData.fromJson(Map<String, dynamic> json) {
    return DictData(
      value: json['value']?.toString() ?? '',
      label: json['label'] as String? ?? '',
      sort: json['sort'] as int? ?? 0,
      colorType: json['colorType'] as String?,
    );
  }
}

/// 字典状态
class DictState {
  final Map<String, List<DictData>> dictMap;
  final bool isLoading;

  const DictState({
    this.dictMap = const {},
    this.isLoading = false,
  });

  DictState copyWith({
    Map<String, List<DictData>>? dictMap,
    bool? isLoading,
  }) {
    return DictState(
      dictMap: dictMap ?? this.dictMap,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// 获取字典列表
  List<DictData> getDict(String dictType) => dictMap[dictType] ?? [];

  /// 根据值获取标签
  String getLabel(String dictType, String value) {
    final dict = getDict(dictType);
    final item = dict.firstWhere(
      (e) => e.value == value,
      orElse: () => const DictData(value: '', label: '-'),
    );
    return item.label;
  }
}

/// 字典状态管理器
class DictStore extends Notifier<DictState> {
  SharedPreferences? _prefs;
  static const String _dictCacheKey = 'dict_cache';

  @override
  DictState build() {
    _loadCachedDict();
    return const DictState();
  }

  /// 加载缓存的字典
  Future<void> _loadCachedDict() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final cacheJson = _prefs!.getString(_dictCacheKey);
      if (cacheJson != null && cacheJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(cacheJson);
        final Map<String, List<DictData>> dictMap = {};
        decoded.forEach((key, value) {
          if (value is List) {
            dictMap[key] = value
                .map((e) => DictData.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        });
        state = state.copyWith(dictMap: dictMap);
      }
    } catch (e) {
      // 忽略读取错误
    }
  }

  /// 设置字典数据
  Future<void> setDict(String dictType, List<DictData> data) async {
    final newMap = Map<String, List<DictData>>.from(state.dictMap);
    newMap[dictType] = data;

    _prefs ??= await SharedPreferences.getInstance();
    final Map<String, dynamic> cacheMap = {};
    newMap.forEach((key, value) {
      cacheMap[key] = value.map((e) => {
        'value': e.value,
        'label': e.label,
        'sort': e.sort,
        'colorType': e.colorType,
      }).toList();
    });
    await _prefs!.setString(_dictCacheKey, jsonEncode(cacheMap));

    state = state.copyWith(dictMap: newMap);
  }

  /// 批量设置字典数据
  Future<void> setDicts(Map<String, List<DictData>> dicts) async {
    final newMap = Map<String, List<DictData>>.from(state.dictMap);
    newMap.addAll(dicts);

    _prefs ??= await SharedPreferences.getInstance();
    final Map<String, dynamic> cacheMap = {};
    newMap.forEach((key, value) {
      cacheMap[key] = value.map((e) => {
        'value': e.value,
        'label': e.label,
        'sort': e.sort,
        'colorType': e.colorType,
      }).toList();
    });
    await _prefs!.setString(_dictCacheKey, jsonEncode(cacheMap));

    state = state.copyWith(dictMap: newMap);
  }

  /// 清除字典缓存
  Future<void> clearCache() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_dictCacheKey);
    state = const DictState();
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// 字典状态提供者
final dictStoreProvider = NotifierProvider<DictStore, DictState>(
  DictStore.new,
);