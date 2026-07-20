// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'cache_service.dart';
import 'api_service.dart';

class RepairResult {
  final String name;
  final bool ok;
  final String detail;
  final bool fixed;
  RepairResult(this.name, this.ok, this.detail, {this.fixed = false});
}

/// 修复中心：启动自动诊断 + 手动修复。
/// 涵盖：网络、配置、缓存、存储四大类，任何修复失败都不会抛异常。
class RepairService {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;

  RepairService(this.config, this.cache, this.api);

  /// 网络连通性检测
  Future<RepairResult> _checkNetwork() async {
    try {
      final resp = await http
          .get(Uri.parse('https://www.bing.com'), headers: {
            'User-Agent': 'Mozilla/5.0'
          }).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        return RepairResult('网络连通性', true, '网络正常，可访问外网。');
      }
      return RepairResult('网络连通性', false, '服务器返回 ${resp.statusCode}，但可连通。');
    } on SocketException {
      return RepairResult('网络连通性', false, '无法连接网络，请检查 Wi-Fi/移动数据。');
    } catch (e) {
      return RepairResult('网络连通性', false, '网络检测异常：$e');
    }
  }

  /// 配置完整性检测
  RepairResult _checkConfig() {
    try {
      // 1) 常规读取，确认基础读写可用
      config.getFollowList();
      config.get<String>('apibyte_key', '');
      // 2) 结构校验：rawGet 在存储异常或类型不匹配（配置损坏）时会抛错。
      //    注意：未写入的 key 返回 null 属于正常（首装），只校验“非 null 却类型错误”。
      final follow = config.rawGet('follow_list');
      if (follow != null && follow is! List) {
        return RepairResult('配置文件', false, '关注列表数据结构异常，可能已损坏。');
      }
      final ak = config.rawGet('apibyte_key');
      if (ak != null && ak is! String) {
        return RepairResult('配置文件', false, '配置项类型异常，可能已损坏。');
      }
      return RepairResult('配置文件', true, '配置读写正常。');
    } catch (e) {
      return RepairResult('配置文件', false, '配置读取失败：$e');
    }
  }

  /// 缓存检测
  RepairResult _checkCache() {
    if (cache.broken) {
      return RepairResult('本地缓存', false, '缓存状态异常，建议清理。');
    }
    return RepairResult('本地缓存', true, '缓存正常（当前 ${cache.size} 条）。');
  }

  Future<List<RepairResult>> diagnose() async {
    final results = <RepairResult>[];
    results.add(await _checkNetwork());
    results.add(_checkConfig());
    results.add(_checkCache());
    return results;
  }

  /// 自动修复：在启动与出错时静默调用。返回修复记录（仅含真正执行了的）。
  Future<List<RepairResult>> autoRepair() async {
    final fixed = <RepairResult>[];

    // 1) 配置损坏 → 重置（依赖 _checkConfig 真正探测损坏，而非永远通过的 get）
    if (!_checkConfig().ok) {
      final ok = await config.reset();
      fixed.add(RepairResult('配置文件', ok,
          ok ? '检测到配置损坏，已重置为默认设置。' : '配置重置失败。',
          fixed: true));
    }

    // 2) 缓存损坏 → 清理
    if (cache.broken) {
      cache.clear();
      fixed.add(RepairResult('本地缓存', !cache.broken,
          !cache.broken ? '检测到缓存异常，已清理本地缓存。' : '缓存清理失败。',
          fixed: true));
    }

    return fixed;
  }

  /// 手动修复：完整诊断 + 执行全部可修复项，返回报告。
  Future<List<RepairResult>> runRepair() async {
    final report = <RepairResult>[];

    final net = await _checkNetwork();
    report.add(net);

    // 配置修复
    if (!_checkConfig().ok) {
      final ok = await config.reset();
      report.add(RepairResult('配置文件', ok,
          ok ? '已重置为默认设置。' : '配置重置失败，请尝试重装。',
          fixed: true));
    } else {
      report.add(RepairResult('配置文件', true, '无需修复。'));
    }

    // 缓存修复
    if (cache.broken || cache.size > 200) {
      cache.clear();
      report.add(RepairResult('本地缓存', !cache.broken,
          !cache.broken ? '已清理本地缓存（${cache.size} 条）。' : '缓存清理失败。',
          fixed: true));
    } else {
      report.add(RepairResult('本地缓存', true, '无需修复。'));
    }

    return report;
  }
}
