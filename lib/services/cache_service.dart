// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'dart:convert';

/// 缓存服务：会话级内存缓存。全程容错，任何序列化/反序列化异常都不会上抛。
class CacheService {
  final Map<String, String> _mem = {};
  bool broken = false;

  void put(String key, dynamic value) {
    try {
      _mem[key] = jsonEncode(value);
    } catch (e) {
      broken = true;
    }
  }

  T? get<T>(String key) {
    try {
      final raw = _mem[key];
      if (raw == null) return null;
      return jsonDecode(raw) as T;
    } catch (e) {
      broken = true;
      return null;
    }
  }

  bool contains(String key) => _mem.containsKey(key);

  void clear() {
    try {
      _mem.clear();
      broken = false;
    } catch (e) {
      broken = true;
    }
  }

  int get size => _mem.length;
}
