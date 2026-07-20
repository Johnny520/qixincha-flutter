// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
class Company {
  final String name;
  final String? creditCode;
  final String? legalPerson;
  final String? status;
  final String? registeredCapital;
  final String? establishDate;
  final String? regAddress;
  final Map<String, dynamic> extra;

  Company({
    required this.name,
    this.creditCode,
    this.legalPerson,
    this.status,
    this.registeredCapital,
    this.establishDate,
    this.regAddress,
    this.extra = const {},
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final extra = Map<String, dynamic>.from(json);
    extra.remove('name');
    extra.remove('creditCode');
    extra.remove('legalPerson');
    extra.remove('status');
    extra.remove('registeredCapital');
    extra.remove('establishDate');
    extra.remove('regAddress');
    return Company(
      name: (json['name'] ?? '').toString(),
      creditCode: _str(json['creditCode']),
      legalPerson: _str(json['legalPerson']),
      status: _str(json['status']),
      registeredCapital: _str(json['registeredCapital']),
      establishDate: _str(json['establishDate']),
      regAddress: _str(json['regAddress']),
      extra: extra,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'creditCode': creditCode,
      'legalPerson': legalPerson,
      'status': status,
      'registeredCapital': registeredCapital,
      'establishDate': establishDate,
      'regAddress': regAddress,
      ...extra,
    };
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
