import 'package:flutter/material.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

import 'package:mgdb/core/theme/app_theme.dart';

import '../presentation/home/home_page.dart';

import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/api_config_provider.dart';
import 'package:mgdb/shared/preferences.dart';

import 'injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appPrefs = AppPreferences();
  await appPrefs.init();

  configureDependencies();

  final userProvider = getIt<UserProvider>();

  await userProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(getIt<AppPreferences>()),
        ),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<ConnectivityProvider>.value(
          value: getIt<ConnectivityProvider>(),
        ),
        ChangeNotifierProvider<ApiConfigProvider>.value(
          value: getIt<ApiConfigProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const Home(),
    );
  }
}
