import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class EinstellungenScreen extends StatelessWidget {
  const EinstellungenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: const Text('Passwort ändern', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Neues Passwort festlegen'),
              leading: const Icon(Icons.lock),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPasswordDialog(context),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Abmelden', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwort ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Neues Passwort',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort bestätigen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bitte Passwort eingeben'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwörter stimmen nicht überein'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Provider.of<AuthProvider>(context, listen: false)
                  .setPassword(passwordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwort wurde erfolgreich geändert'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchtest du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
  }
}
