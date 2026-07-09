import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动免责声明服务。
/// 使用独立的 SharedPreferences 标志位（不带 qxc_ 前缀，避免被配置重置误删）。
class DisclaimerService {
  static const String _key = 'disclaimer_agreed';

  /// 免责声明文案（对齐 Android / Python 版口径）。
  static const String disclaimerText = '''【数据来源与免责声明】

企信查 是一款个人学习作品，用于演示类「天眼查」风格的企业信息检索功能。

★ 数据来源
本软件通过公开 / 免费 API 与公开网页获取企业工商信息；未配置任何 key 时，自动启用「免费网页抓取」兜底（best-effort，能爬才爬）。

★ 重要说明
1. 本软件仅供学习、研究和技术交流使用，请勿用于任何商业或违法用途。
2. 数据由第三方接口 / 公开网页提供，其准确性、完整性、时效性以官方登记为准，本软件不作任何保证。
3. 请遵守各数据平台的服务条款，并在其官网合规申请与使用 API key；网页抓取仅用于公开信息，请合理控制频率。
4. 因使用本软件产生的任何后果，由使用者自行承担。

点击「我已阅读并同意」即表示你已知晓并接受以上内容。''';

  /// 是否已同意过免责声明。
  static Future<bool> isAgreed() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getBool(_key) ?? false;
    } catch (e) {
      // 读取失败保守当作未同意，让用户重新确认
      return false;
    }
  }

  /// 标记已同意免责声明。
  static Future<bool> agree() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return await sp.setBool(_key, true);
    } catch (e) {
      return false;
    }
  }
}
