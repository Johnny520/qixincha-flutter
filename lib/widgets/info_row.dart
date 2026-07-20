// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';
import '../theme.dart';

/// 统一的「键 - 值」信息行，详情页与对比页复用，保证视觉与排版一致。
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: const TextStyle(color: Palette.sub, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Palette.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
