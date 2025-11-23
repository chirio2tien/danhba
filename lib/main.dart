import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/isar_service.dart';
import 'providers/contact_providers.dart';
import 'ui/screens/home_screen.dart';
import 'repositories/profile_repository.dart';
import 'providers/group_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance();
  await ProfileRepository().getProfile();
  

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final lightTheme = ThemeData(
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      useMaterial3: true,
    );
    final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1), brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}