import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme.dart';

class DetailScreen extends StatelessWidget {
  final Company company;
  const DetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // 收集要展示的字段
    final display = <String, String>{
      if (company.creditCode != null) '统一社会信用代码': company.creditCode!,
      if (company.legalPerson != null) '法定代表人': company.legalPerson!,
      if (company.status != null) '登记状态': company.status!,
      if (company.registeredCapital != null) '注册资本': company.registeredCapital!,
      if (company.establishDate != null) '成立日期': company.establishDate!,
      if (company.regAddress != null) '注册地址': company.regAddress!,
      ...company.extra.map((k, v) => MapEntry(k, v.toString())),
    };

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
                            .map((e) => _row(e.key, e.value))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: const TextStyle(color: Palette.sub, fontSize: 14)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(color: Palette.text, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
