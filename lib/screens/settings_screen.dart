import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/config_service.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';
import '../services/repair_service.dart';
import '../theme.dart';
import '../services/disclaimer_service.dart';

class SettingsScreen extends StatefulWidget {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;
  final RepairService repair;
  const SettingsScreen({
    super.key,
    required this.config,
    required this.cache,
    required this.api,
    required this.repair,
  });
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Map<String, TextEditingController> _keys;
  bool _scrape = true;
  String _version = '';
  bool _repairing = false;

  @override
  void initState() {
    super.initState();
    _keys = {
      'apibyte_key': TextEditingController(text: widget.config.get<String>('apibyte_key', '')),
      'jisu_key': TextEditingController(text: widget.config.get<String>('jisu_key', '')),
      'juhe_key': TextEditingController(text: widget.config.get<String>('juhe_key', '')),
      'xxapi_key': TextEditingController(text: widget.config.get<String>('xxapi_key', '')),
    };
    _scrape = widget.config.get<bool>('use_scrape_fallback', true);
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (e) {
      if (mounted) setState(() => _version = '1.3.0');
    }
  }

  Future<void> _saveKeys() async {
    for (final e in _keys.entries) {
      await widget.config.set(e.key, e.value.text.trim());
    }
    await widget.config.set('use_scrape_fallback', _scrape);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  Future<void> _runRepair() async {
    setState(() => _repairing = true);
    List<RepairResult> report;
    try {
      report = await widget.repair.runRepair();
    } catch (e) {
      report = [RepairResult('修复中心', false, '修复过程异常：$e')];
    }
    if (mounted) {
      setState(() => _repairing = false);
      _showReport(report);
    }
  }

  void _showReport(List<RepairResult> report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修复报告'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: report.map((r) {
              final color = r.ok ? Palette.ok : Palette.err;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(r.fixed ? Icons.build : (r.ok ? Icons.check_circle : Icons.error), color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${r.name}：${r.detail}', style: TextStyle(color: color))),
                ]),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('免责声明'),
        content: SingleChildScrollView(
          child: Text(DisclaimerService.disclaimerText,
              style: const TextStyle(fontSize: 13, height: 1.6)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(w * 0.04),
        children: [
          _sectionTitle('数据来源（免费 API 密钥，可选）'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _keyField('apibyte_key', 'ApiByte 密钥'),
                  _keyField('juhe_key', '聚合数据(Juhe) 密钥'),
                  _keyField('jisu_key', '极速数据(Jisu) 密钥'),
                  _keyField('xxapi_key', 'XXApi 密钥'),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('无密钥时启用网页兜底抓取'),
                    value: _scrape,
                    onChanged: (v) => setState(() => _scrape = v),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _saveKeys, child: const Text('保存设置')),
                  ),
                  const SizedBox(height: 6),
                  const Text('未配置密钥时，App 会通过网页抓取提供基础信息；填入密钥后可获取完整工商数据。',
                      style: TextStyle(color: Palette.sub, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('修复中心'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('如遇网络异常、配置损坏、缓存错误，可一键自动诊断并修复。',
                      style: TextStyle(color: Palette.sub, fontSize: 13)),
                  const SizedBox(height: 10),
                  _repairing
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('一键诊断与修复'),
                            onPressed: _runRepair,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('数据与缓存'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services),
                  title: const Text('清理本地缓存'),
                  subtitle: Text('当前 ${widget.cache.size} 条'),
                  onTap: () {
                    widget.cache.clear();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清理')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('重置所有设置'),
                  onTap: () async {
                    await widget.config.reset();
                    for (final e in _keys.entries) e.value.text = '';
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已重置为默认设置')));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('协议与关于'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('免责声明'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDisclaimer(context),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('关于'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('企信查'),
              subtitle: Text('版本 $_version\nFlutter 重写版 · 类天眼查企业查询'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _keys[key],
        decoration: InputDecoration(labelText: label, hintText: '留空则不使用'),
        obscureText: true,
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: Palette.primary, fontSize: 14)),
    );
  }
}
