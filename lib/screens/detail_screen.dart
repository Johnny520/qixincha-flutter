// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme.dart';
import '../widgets/info_row.dart';
import '../widgets/company_fields.dart';

class DetailScreen extends StatelessWidget {
  final Company company;
  const DetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // 收集要展示的字段
    final display = companyDisplayFields(company);

    return Scaffold(
      appBar: AppBar(title: Text(company.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(w * 0.04),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Palette.text)),
                    const SizedBox(height: 8),
                    if (company.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Palette.ok.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(company.status!, style: const TextStyle(color: Palette.ok, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: display.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('暂无详细数据。', style: TextStyle(color: Palette.sub)),
                      )
                    : Column(
                        children: display.entries
                            .map((e) => KeyValueRow(label: e.key, value: e.value))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
