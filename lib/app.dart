import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/routes/app_router.dart';
import 'package:mobile/core/widgets/global_loading_overlay.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Sakura Kanji',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) {
        return GlobalLoadingOverlay(child: child!);
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
