import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodex/core/router/app_router.dart';
import 'package:kyodex/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await getInitialRoute();
  appRouter.configuration.navigatorKey;

  runApp(ProviderScope(child: KyoDexApp(initialRoute: initialRoute)));
}

class KyoDexApp extends StatelessWidget {
  final String initialRoute;
  const KyoDexApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KyoDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}