import 'package:flutter/material.dart';
import '../models/company.dart';
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
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
                  final report = await widget.repair.runRepair();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('修复完成：${report.where((r) => r.fixed).length} 项已处理')),
                    );
                    _doSearch();
                  }
                },
                child: const Text('去修复中心修复'),
              ),
            ],
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_center_outlined, size: 56, color: Palette.sub),
            SizedBox(height: 12),
            Text('输入企业名称开始查询', style: TextStyle(color: Palette.sub)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (ctx, i) {
        final c = _results[i];
        return CompanyCard(
          company: c,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(company: c)),
          ),
        );
      },
    );
  }
}
