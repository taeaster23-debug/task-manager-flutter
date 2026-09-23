import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: const Text('Signed in as'), subtitle: Text(user?.email ?? 'Unknown'))),
        const SizedBox(height: 12),
        Card(child: SwitchListTile(title: const Text('Dark Mode'), subtitle: const Text('Switch between light and dark theme'), secondary: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode), value: theme.isDark, onChanged: theme.toggle)),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(onPressed: () async { await context.read<AuthProvider>().signOut(); if (context.mounted) Navigator.pop(context); }, icon: const Icon(Icons.logout), label: const Text('Sign Out')),
      ],),
    );
  }
}
