// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/config_service.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/info_row.dart';
import '../widgets/company_fields.dart';

class CompareScreen extends StatefulWidget {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;
  const CompareScreen({
    super.key,
    required this.config,
    required this.cache,
    required this.api,
  });
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  Company? _ca;
  Company? _cb;
  bool _loading = false;

  Future<void> _compare() async {
    final a = _a.text.trim();
    final b = _b.text.trim();
    if (a.isEmpty || b.isEmpty) return;
    setState(() => _loading = true);
    try {
      final ca = await widget.api.getDetail(a);
      final cb = await widget.api.getDetail(b);
      // 接口可能返回 null（如未配置密钥且无抓取结果），回退为基础企业对象，避免对比页空白。
      _ca = ca ?? Company(name: a);
      _cb = cb ?? Company(name: b);
    } catch (e) {
      _ca = Company(name: a);
      _cb = Company(name: b);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final twoCol = w > 600;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _a, decoration: const InputDecoration(hintText: '企业 A'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _b, decoration: const InputDecoration(hintText: '企业 B'))),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loading ? null : _compare, child: const Text('开始对比')),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading && _ca != null && _cb != null)
              twoCol
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: _col(_ca!)),
                      const SizedBox(width: 12),
                      Expanded(child: _col(_cb!)),
                    ])
                  : Column(children: [
                      _col(_ca!),
                      const SizedBox(height: 12),
                      _col(_cb!),
                    ]),
          ],
        ),
      ),
    );
  }

  Widget _col(Company c) {
    final display = companyDisplayFields(c);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: Palette.text)),
            const Divider(),
            ...display.entries
                .map((e) => KeyValueRow(label: e.key, value: e.value)),
            if (display.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('暂无对比数据', style: TextStyle(color: Palette.sub)),
              ),
          ],
        ),
      ),
    );
  }
}
