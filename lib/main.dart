import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/config_service.dart';
import 'services/cache_service.dart';
import 'services/api_service.dart';
import 'services/repair_service.dart';
import 'screens/search_screen.dart';
import 'screens/follow_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const AppLoader());

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});
  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late final ConfigService config;
  late final CacheService cache;
  late final ApiService api;
  late final RepairService repair;
  bool ready = false;
  List<RepairResult> startupFixes = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    config = ConfigService();
    cache = CacheService();
    api = ApiService(config, cache);
    repair = RepairService(config, cache, api);
    try {
      await config.init();
    } catch (e) {
      // 存储不可用也应继续运行
    }
    try {
      startupFixes = await repair.autoRepair();
    } catch (e) {
      startupFixes = [];
    }
    if (mounted) setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: qxTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return QxApp(
      config: config,
      cache: cache,
      api: api,
      repair: repair,
      startupFixes: startupFixes,
    );
  }
}

class QxApp extends StatefulWidget {
  final ConfigService config;
  final CacheService cache;
  final ApiService api;
  final RepairService repair;
  final List<RepairResult> startupFixes;
  const QxApp({
    super.key,
    required this.config,
    required this.cache,
    required this.api,
    required this.repair,
    required this.startupFixes,
  });
  @override
  State<QxApp> createState() => _QxAppState();
}

class _QxAppState extends State<QxApp> {
  int _tab = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SearchScreen(
        config: widget.config,
        cache: widget.cache,
        api: widget.api,
        repair: widget.repair,
      ),
      FollowScreen(
        config: widget.config,
        cache: widget.cache,
        api: widget.api,
      ),
      CompareScreen(
        config: widget.config,
        cache: widget.cache,
        api: widget.api,
      ),
      SettingsScreen(
        config: widget.config,
        cache: widget.cache,
        api: widget.api,
        repair: widget.repair,
      ),
    ];
  }

  static const _tabs = [
    (icon: Icons.search, label: '搜索'),
    (icon: Icons.star_outline, label: '关注'),
    (icon: Icons.compare_arrows, label: '对比'),
    (icon: Icons.settings, label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '企信查',
      theme: qxTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('企信查'),
          centerTitle: true,
          actions: [
            if (widget.startupFixes.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.auto_fix_high),
                tooltip: '本次启动已自动修复 ${widget.startupFixes.length} 项',
                onPressed: () => _showFixes(context),
              ),
          ],
        ),
        body: IndexedStack(index: _tab, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(icon: Icon(t.icon), label: t.label),
          ],
        ),
      ),
    );
  }

  void _showFixes(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('启动自动修复'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.startupFixes
                .map((f) => Text('• ${f.name}：${f.detail}'))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
