// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import '../models/company.dart';

/// 从 Company 提取用于展示的「字段名 -> 值」有序映射。
/// 详情页与对比页共用，保证字段口径与顺序一致。
Map<String, String> companyDisplayFields(Company c) => {
      if (c.creditCode != null) '统一社会信用代码': c.creditCode!,
      if (c.legalPerson != null) '法定代表人': c.legalPerson!,
      if (c.status != null) '登记状态': c.status!,
      if (c.registeredCapital != null) '注册资本': c.registeredCapital!,
      if (c.establishDate != null) '成立日期': c.establishDate!,
      if (c.regAddress != null) '注册地址': c.regAddress!,
      ...c.extra.map((k, v) => MapEntry(k, v.toString())),
    };
