import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/pages/home_page.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'BuddyExpense',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
