import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'services/config_service.dart';
import 'services/cache_service.dart';
import 'services/api_service.dart';
import 'services/repair_service.dart';
import 'services/disclaimer_service.dart';
import 'screens/search_screen.dart';
import 'screens/follow_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  // 顶层异常兜底：用 Zone 捕获未处理的异步异常，避免直接红屏闪退。
  runZonedGuarded<void>(() {
    WidgetsFlutterBinding.ensureInitialized();
    // 框架内的同步错误也降级为错误页，而不是直接红屏。
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
    ErrorWidget.builder = (details) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            '界面出现异常，请尝试重启应用。\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    };
    runApp(const AppLoader());
  }, (error, stack) {
    debugPrint('未捕获的异步异常：$error');
    debugPrint(stack.toString());
  });
}

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
  bool agreed = false;
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
      // 包一层超时，避免个别 ROM 上 SharedPreferences 异常导致永久卡启动页。
      await config.init().timeout(const Duration(seconds: 5), onTimeout: () {
        // 超时也继续，App 退回纯内存默认配置运行。
      });
    } catch (e) {
      // 存储不可用也应继续运行
    }
    try {
      startupFixes = await repair.autoRepair();
    } catch (e) {
      startupFixes = [];
    }
    // 首次启动免责声明：未同意则先弹声明页，同意后才进入主界面。
    try {
      agreed = await DisclaimerService.isAgreed();
    } catch (e) {
      agreed = false;
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
    // 首次启动：未同意免责声明，先展示声明页（同意进入 / 不同意退出）。
    if (!agreed) {
      return _buildDisclaimerGate();
    }
    return QxApp(
      config: config,
      cache: cache,
      api: api,
      repair: repair,
      startupFixes: startupFixes,
    );
  }

  Widget _buildDisclaimerGate() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: qxTheme(),
      home: Scaffold(
        appBar: AppBar(title: const Text('免责声明')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    DisclaimerService.disclaimerText,
                    style: const TextStyle(fontSize: 14, height: 1.6, color: Palette.text),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 不同意：退出应用（Android/iOS 会关闭，桌面/Web 无效果但不崩溃）。
                          SystemNavigator.pop();
                        },
                        child: const Text('不同意并退出'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await DisclaimerService.agree();
                          if (mounted) setState(() => agreed = true);
                        },
                        child: const Text('我已阅读并同意'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
