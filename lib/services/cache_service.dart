import 'dart:convert';

/// 缓存服务：内存缓存 + 轻量持久化。全程容错。
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
