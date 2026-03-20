import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/marketplace_page.dart';
import 'pages/calendar_view_page.dart';
import 'pages/alarm_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_header.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

const Color kPrimary = Color(0xFFF57C00);
const Color kPrimaryDark = Color(0xFFE65100);
const Color kDark = Color(0xFF1C1C1C);
const Color kLight = Color(0xFFF7F7F7);

// Dark Mode Colors
const Color kDarkBg = Color(0xFF121212);
const Color kDarkSurface = Color(0xFF1E1E1E);
const Color kDarkText = Color(0xFFE1E1E1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final base = ThemeData.light();
    final darkBase = ThemeData.dark();

    return MaterialApp(
      title: 'Fallega',
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.themeMode,
      locale: appProvider.locale,
      theme: base.copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kLight,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kDark,
          elevation: 0,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: kDark,
          displayColor: kDark,
        ),
      ),
      darkTheme: darkBase.copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          brightness: Brightness.dark,
          surface: kDarkSurface,
        ),
        scaffoldBackgroundColor: kDarkBg,
        cardColor: kDarkSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkSurface,
          foregroundColor: kDarkText,
          elevation: 0,
        ),
        textTheme: darkBase.textTheme.apply(
          bodyColor: kDarkText,
          displayColor: kDarkText,
        ),
      ),
      home: appProvider.isLoggedIn ? const RootShell() : const LoginPage(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;
  int previousIndex = 0;
  final pages = const [
    DashboardPage(),
    MarketplacePage(),
    CalendarViewPage(),
    _PlaceholderPage(title: 'Chat'),
    AlarmPage(),
    ProfilePage(),
    NotificationsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isSubPage = index >= 6;

    final titles = [
      appProvider.translate('Dashboard', 'Dashboard'),
      appProvider.translate('Marketplace', 'Marketplace'),
      appProvider.translate('Calendrier', 'Calendar'),
      appProvider.translate('Chat', 'Chat'),
      appProvider.translate('Réveil', 'Alarm'),
      appProvider.translate('Profil', 'Profile'),
      appProvider.translate('Notifications', 'Notifications'),
      appProvider.translate('Paramètres', 'Settings'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: titles[index],
              showSearch: index == 0,
              onProfileTap: () => setState(() {
                previousIndex = index;
                index = 5;
              }),
              onNotificationsTap: () => setState(() {
                previousIndex = index;
                index = 6;
              }),
              onSettingsTap: () => setState(() {
                previousIndex = index;
                index = 7;
              }),
              onBackTap: isSubPage ? () => setState(() => index = previousIndex) : null,
            ),
            Expanded(child: pages[index]),
          ],
        ),
      ),
      bottomNavigationBar: index < 6 ? AppBottomNav(
        selectedIndex: index,
        onSelected: (i) => setState(() => index = i),
      ) : null,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: kDark),
      ),
    );
  }
}
