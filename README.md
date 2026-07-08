# 企信查（Flutter 版）

类天眼查风格的企业信息查询 App，使用 **Flutter (Dart)** 重写，彻底解决旧版 Python/Kivy 在 Android 上闪退的问题。

## 功能
- 🔍 企业搜索：按名称查询，结果列表自适应展示
- 📄 企业详情：统一社会信用代码、法定代表人、注册资本、成立日期等
- ⭐ 关注列表：收藏常用企业
- 🆚 企业对比：并排对比两家企业的关键信息
- 🛠 修复中心：启动自动诊断+修复，以及手动一键修复（网络/配置/缓存）
- 🌐 数据来源：可选接入免费 API 密钥；未配置时通过网页抓取提供基础信息

## 技术栈
- Flutter 3.x / Dart 3.x
- HTTP 数据获取 + 网页兜底抓取
- `shared_preferences` 本地配置与缓存
- 包名：`com.qxx.johnny`

## 构建
推送到 `v*` tag 会自动触发 GitHub Actions 构建可安装的 Release APK。
本仓库的发布说明（Release body）自动从 `CHANGELOG.md` 提取对应版本段落生成。

## 更新描述
每次 GitHub 更新/发布都会带更新描述：修复了哪些问题、更新了哪些内容，
见 `CHANGELOG.md`。
