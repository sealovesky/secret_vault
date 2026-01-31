import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_provider.dart';
import '../l10n/app_localizations.dart';
import 'passwords_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';

/// 主页 - 底部导航
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PasswordsScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.key_outlined),
            selectedIcon: const Icon(Icons.key),
            label: l10n.passwords,
          ),
          NavigationDestination(
            icon: const Icon(Icons.note_outlined),
            selectedIcon: const Icon(Icons.note),
            label: l10n.notes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
