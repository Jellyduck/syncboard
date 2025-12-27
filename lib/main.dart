// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'route/app_routes.dart';
import 'providers/app_providers.dart';
import 'features/auth/login_page.dart';
import 'features/category/category_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '', // Supabase 项目 URL
    anonKey: '', // Supabase key
  );

  runApp(
    ProviderScope(
      child: OKToast(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 Auth 状态
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      onGenerateRoute: AppRoutes.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],

      // 根据session决定初始页面
      home: authState.when(
        data: (user) {
          if (user != null) {
            // 已登录，显示分类页
            return const CategoryPage();
          } else {
            // 未登录，显示登录页
            return const LoginPage();
          }
        },
        // 加载状态
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()), // 显示启动转圈
        ),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('加载失败: $err'))),
      ),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // 禁用系统字体缩放
          ),
          child: child!,
        );
      },
    );
  }
}
