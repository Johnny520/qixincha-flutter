// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme.dart';
import '../services/config_service.dart';
import '../services/cache_service.dart';
import '../services/api_service.dart';
import '../widgets/company_card.dart';
import 'detail_screen.dart';

class FollowScreen extends StatefulWidget {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;
  const FollowScreen({
    super.key,
    required this.config,
    required this.cache,
    required this.api,
  });
  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  List<String> _list = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _list = widget.config.getFollowList());
  }

  Future<void> _open(String name) async {
    final detail = await widget.api.getDetail(name);
    if (mounted && detail != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(company: detail)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _list.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline, size: 56, color: Palette.sub),
                  SizedBox(height: 12),
                  Text('还没有关注的企业', style: TextStyle(color: Palette.sub)),
                  SizedBox(height: 4),
                  Text('在搜索结果中可加入关注', style: TextStyle(color: Palette.sub, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _list.length,
              itemBuilder: (ctx, i) {
                final name = _list[i];
                return CompanyCard(
                  company: Company(name: name),
                  onTap: () => _open(name),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Palette.warn),
                    onPressed: () async {
                      await widget.config.toggleFollow(name);
                      _refresh();
                    },
                  ),
                );
              },
            ),
    );
  }
}
