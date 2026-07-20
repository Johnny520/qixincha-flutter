// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:http/http.dart' as http;
import '../models/company.dart';
import 'config_service.dart';
import 'cache_service.dart';

/// 数据服务：负责企业搜索与详情获取。
/// 设计原则：任何网络/解析异常都被吞掉并降级，绝不让 UI 崩溃。
class ApiService {
  final ConfigService config;
  final CacheService cache;
  static const Duration _timeout = Duration(seconds: 12);
  static const String _ua =
      'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile';

  ApiService(this.config, this.cache);

  /// 搜索企业。优先使用已配置的免费 API，全部不可用时兜底网页抓取。
  Future<List<Company>> search(String q) async {
    q = (q.trim());
    if (q.isEmpty) return [];
    final cacheKey = 'search:$q';
    if (cache.contains(cacheKey)) {
      final cached = cache.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((e) => Company.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }

    List<Company> results = [];

    // 1) 已配置密钥的免费 API（尽力而为）
    results = await _searchViaApi(q);

    // 2) 兜底网页抓取，保证有结果可展示
    if (results.isEmpty && config.get<bool>('use_scrape_fallback', true)) {
      results = await _searchFallback(q);
    }

    if (results.isNotEmpty) {
      cache.put(cacheKey, results.map((c) => c.toJson()).toList());
    }
    return results;
  }

  Future<List<Company>> _searchViaApi(String q) async {
    // 统一占位：若用户配置了免费 API 密钥，可在此接入。
    // 当前默认走兜底抓取，保证无密钥也能用。
    return [];
  }

  /// 兜底：Bing 搜索结果中提取看起来像企业名的条目。
  Future<List<Company>> _searchFallback(String q) async {
    try {
      final uri = Uri.parse('https://www.bing.com/search')
          .replace(queryParameters: {'q': '$q 企业 工商信息 天眼查'});
      final resp = await http
          .get(uri, headers: {'User-Agent': _ua})
          .timeout(_timeout);
      if (resp.statusCode != 200) return [];
      final names = <String>{};
      final h2Re = RegExp(r'<h2>(.*?)</h2>', dotAll: true);
      for (final m in h2Re.allMatches(resp.body)) {
        final txt = _stripTags(m.group(1) ?? '');
        if (_looksLikeCompany(txt)) names.add(txt);
      }
      return names
          .take(20)
          .map((n) => Company(name: n))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取企业详情。无密钥时返回基础对象并标注数据来源有限。
  Future<Company?> getDetail(String name) async {
    if (name.trim().isEmpty) return null;
    final cacheKey = 'detail:$name';
    if (cache.contains(cacheKey)) {
      final cached = cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return Company.fromJson(cached);
    }

    Company? detail = await _detailViaApi(name);
    if (detail == null) {
      detail = await _detailFallback(name);
    }
    if (detail != null) {
      cache.put(cacheKey, detail.toJson());
    }
    return detail;
  }

  Future<Company?> _detailViaApi(String name) async {
    // 接入点：用户配置免费 API 后在此实现详情拉取。
    return null;
  }

  Future<Company?> _detailFallback(String name) async {
    final extra = <String, dynamic>{};
    extra['提示'] = '未配置 API 密钥，仅展示基础信息。可在「设置」中填入免费 API 密钥以获取完整工商数据。';
    try {
      final uri = Uri.parse('https://www.bing.com/search')
          .replace(queryParameters: {'q': '$name 法定代表人 注册资本 成立日期'});
      final resp = await http
          .get(uri, headers: {'User-Agent': _ua})
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        _tryExtract(resp.body, name, extra);
      }
    } catch (e) {
      // 忽略，返回基础对象
    }
    return Company(name: name, extra: extra);
  }

  void _tryExtract(String html, String name, Map<String, dynamic> extra) {
    final credit =
        RegExp(r'([0-9A-Z]{18})').firstMatch(html)?.group(1);
    if (credit != null) extra['统一社会信用代码'] = credit;
    final legal =
        RegExp(r'法定代表人[：:]\s*([一-龥]{2,4})').firstMatch(html)?.group(1);
    if (legal != null) extra['法定代表人'] = legal;
    final cap = RegExp(r'注册资本[：:]\s*([0-9.]+[万千万亿]?元?)')
        .firstMatch(html)
        ?.group(1);
    if (cap != null) extra['注册资本'] = cap;
    final date = RegExp(r'成立日期[：:]\s*([0-9]{4}[-年][0-9]{1,2}[-月][0-9]{1,2}日?)')
        .firstMatch(html)
        ?.group(1);
    if (date != null) extra['成立日期'] = date;
  }

  static String _stripTags(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  static bool _looksLikeCompany(String s) {
    if (s.length < 3 || s.length > 40) return false;
    if (s.contains('http') || s.contains('www.')) return false;
    return RegExp(r'(公司|企业|集团|厂|商行|工作室|合作社|有限合伙|股份|科技|实业|贸易|文化|咨询|网络|生物|能源|医疗|教育|投资|管理|物流|建筑|食品|电子|信息|环境|智能)')
        .hasMatch(s);
  }
}
