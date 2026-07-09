import 'package:shared_preferences/shared_preferences.dart';

/// 配置服务：统一读写用户设置（API 密钥、开关、主题等）。
/// 所有读写均带容错，任何异常都不会让 App 崩溃。
class ConfigService {
  static const String _prefix = 'qxc_';

  static const Map<String, dynamic> defaults = {
    'apibyte_key': '',
    'jisu_key': '',
    'juhe_key': '',
    'xxapi_key': '',
    'use_scrape_fallback': true,
    'theme_blue': true,
    'follow_list': <String>[],
  };

  SharedPreferences? _prefs;
  final Map<String, dynamic> _cache = {};

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // 把所有 key 载入内存缓存，避免重复 IO
      for (final key in defaults.keys) {
        _cache[key] = _readRaw(key);
      }
    } catch (e) {
      // 存储不可用时退回纯内存，保证 App 仍可运行
      _prefs = null;
      _cache.addAll(defaults);
    }
  }

  dynamic _readRaw(String key) {
    try {
      if (_prefs == null) return defaults[key];
      if (defaults[key] is List) {
        return _prefs!.getStringList('$_prefix$key') ?? defaults[key];
      }
      if (defaults[key] is bool) {
        return _prefs!.getBool('$_prefix$key') ?? defaults[key];
      }
      if (defaults[key] is int) {
        return _prefs!.getInt('$_prefix$key') ?? defaults[key];
      }
      return _prefs!.getString('$_prefix$key') ?? defaults[key];
    } catch (e) {
      return defaults[key];
    }
  }

  T get<T>(String key, [T? fallback]) {
    if (!_cache.containsKey(key)) {
      _cache[key] = _readRaw(key);
    }
    final v = _cache[key];
    if (v is T) return v;
    if (fallback != null) return fallback;
    return defaults[key] as T;
  }

  /// 原始读取：直接读 SharedPreferences，不做任何容错与类型回退。
  /// 存储不可用或数据损坏（例如某 key 存成了错误类型）时会抛出异常，
  /// 供修复中心探测配置是否损坏并触发 reset。
  dynamic rawGet(String key) {
    if (_prefs == null) {
      throw StateError('存储不可用');
    }
    final full = '$_prefix$key';
    final dv = defaults[key];
    if (dv is List) return _prefs!.getStringList(full);
    if (dv is bool) return _prefs!.getBool(full);
    if (dv is int) return _prefs!.getInt(full);
    return _prefs!.getString(full);
  }

  Future<bool> set<T>(String key, T value) async {
    _cache[key] = value;
    try {
      if (_prefs == null) return false;
      if (value is List) {
        return await _prefs!.setStringList(
            '$_prefix$key', (value as List).map((e) => e.toString()).toList());
      }
      if (value is bool) return await _prefs!.setBool('$_prefix$key', value);
      if (value is int) return await _prefs!.setInt('$_prefix$key', value);
      return await _prefs!.setString('$_prefix$key', value.toString());
    } catch (e) {
      return false;
    }
  }

  Future<bool> reset() async {
    try {
      if (_prefs != null) {
        for (final key in defaults.keys) {
          await _prefs!.remove('$_prefix$key');
        }
      }
      _cache.clear();
      _cache.addAll(defaults);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<String> getFollowList() {
    final v = get<List<dynamic>>('follow_list', []);
    return v.whereType<String>().toList();
  }

  Future<bool> toggleFollow(String name) async {
    final list = getFollowList();
    if (list.contains(name)) {
      list.remove(name);
    } else {
      list.add(name);
    }
    return await set('follow_list', list);
  }
}
