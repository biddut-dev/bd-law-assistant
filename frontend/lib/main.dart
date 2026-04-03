import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/chat_screen.dart';
import 'screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  final isBengali = prefs.getBool('isBengali') ?? false;

  runApp(BDLawApp(isDarkMode: isDarkMode, isBengali: isBengali));
}

class BDLawApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isBengali;

  const BDLawApp({super.key, required this.isDarkMode, required this.isBengali});

  @override
  State<BDLawApp> createState() => _BDLawAppState();

  static _BDLawAppState of(BuildContext context) => context.findAncestorStateOfType<_BDLawAppState>()!;
}

class _BDLawAppState extends State<BDLawApp> {
  late ThemeMode _themeMode;
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _isBengali = widget.isBengali;
  }

  void toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  void toggleLanguage(bool isBengali) async {
    setState(() {
      _isBengali = isBengali;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isBengali', isBengali);
  }

  bool get isBengali => _isBengali;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD Law Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: _themeMode,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChatScreen(),
    const SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = BDLawApp.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.isBengali ? 'বিডি ল অ্যাসিস্ট্যান্ট' : 'BD Law Assistant', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(appState.isBengali ? Icons.language : Icons.language_outlined),
            tooltip: 'Toggle Language',
            onPressed: () {
              appState.toggleLanguage(!appState.isBengali);
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              appState.toggleTheme(!isDark);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: appState.isBengali ? 'চ্যাট' : 'AI Chat',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: appState.isBengali ? 'খুঁজুন' : 'Search Law',
          ),
        ],
      ),
    );
  }
}
