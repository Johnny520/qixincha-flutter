// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../theme.dart';
import '../glass.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback? onTap;
  final Widget? trailing;
  const CompanyCard({
    super.key,
    required this.company,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GlassContainer(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 6),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Palette.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (company.status != null)
                      _chip(company.status!, Palette.primary),
                    if (company.legalPerson != null)
                      _chip('法人：${company.legalPerson}', Palette.sub),
                    if (company.registeredCapital != null)
                      _chip(company.registeredCapital!, Palette.sub),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          const Icon(Icons.chevron_right, color: Palette.sub),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
