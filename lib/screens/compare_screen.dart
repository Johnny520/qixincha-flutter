import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/config_service.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';
import '../theme.dart';

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
    if (_a.text.trim().isEmpty || _b.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      _ca = await widget.api.getDetail(_a.text.trim());
      _cb = await widget.api.getDetail(_b.text.trim());
    } catch (e) {
      _ca = Company(name: _a.text);
      _cb = Company(name: _b.text);
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
    final display = <String, String>{
      if (c.creditCode != null) '信用代码': c.creditCode!,
      if (c.legalPerson != null) '法定代表人': c.legalPerson!,
      if (c.status != null) '登记状态': c.status!,
      if (c.registeredCapital != null) '注册资本': c.registeredCapital!,
      if (c.establishDate != null) '成立日期': c.establishDate!,
      ...c.extra.map((k, v) => MapEntry(k, v.toString())),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Palette.text)),
            const Divider(),
            ...display.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 96, child: Text(e.key, style: const TextStyle(color: Palette.sub))),
                    Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ]),
                )),
            if (display.isEmpty)
              const Text('暂无对比数据', style: TextStyle(color: Palette.sub)),
          ],
        ),
      ),
    );
  }
}
