import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme.dart';
import '../services/config_service.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';
import '../services/repair_service.dart';
import '../widgets/company_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;
  final RepairService repair;
  const SearchScreen({
    super.key,
    required this.config,
    required this.cache,
    required this.api,
    required this.repair,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Company> _results = [];
  bool _loading = false;
  String? _error;
  String? _openingName; // 正在打开详情的企业名（用于加载指示）

  Future<void> _doSearch([String? q]) async {
    final query = (q ?? _ctrl.text).trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.api.search(query);
      if (mounted) {
        setState(() {
          _results = list;
          _loading = false;
          if (list.isEmpty) _error = '未找到相关企业，可尝试更换关键词或检查网络。';
        });
      }
    } catch (e) {
      // 搜索异常时提示可修复
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '搜索出错：$e\n如持续失败，可到「设置→修复中心」一键修复。';
        });
      }
    }
  }

  /// 进入详情前先获取完整工商数据，保证详情页展示完整信息（与关注页一致）。
  Future<void> _openDetail(Company company) async {
    setState(() => _openingName = company.name);
    Company target = company;
    try {
      final detail = await widget.api.getDetail(company.name);
      if (detail != null) target = detail;
    } catch (e) {
      // 获取失败则退回到仅有名称的基础对象，至少能打开详情页。
    }
    if (!mounted) return;
    setState(() => _openingName = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(company: target)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: '输入企业名称，如：腾讯',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: _doSearch,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _loading ? null : () => _doSearch(),
                  child: _loading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('搜索'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    Widget child;
    if (_loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Palette.sub),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Palette.sub)),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  // 统一用 try/catch 包裹，避免未来 runRepair 改动时漏捕导致闪退。
                  try {
                    final report = await widget.repair.runRepair();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('修复完成：${report.where((r) => r.fixed).length} 项已处理')),
                      );
                      _doSearch();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('修复失败：$e')),
                      );
                    }
                  }
                },
                child: const Text('去修复中心修复'),
              ),
            ],
          ),
        ),
      );
    } else if (_results.isEmpty) {
      child = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_center_outlined, size: 56, color: Palette.sub),
            SizedBox(height: 12),
            Text('输入企业名称开始查询', style: TextStyle(color: Palette.sub)),
          ],
        ),
      );
    } else {
      child = ListView.builder(
        itemCount: _results.length,
        itemBuilder: (ctx, i) {
          final c = _results[i];
          return CompanyCard(
            company: c,
            onTap: () => _openDetail(c),
          );
        },
      );
    }
    // 打开详情时的加载指示
    if (_openingName != null) {
      child = Stack(
        children: [
          child,
          Container(
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    return child;
  }
}
