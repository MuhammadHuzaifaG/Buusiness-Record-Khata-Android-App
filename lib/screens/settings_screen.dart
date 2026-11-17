import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/localization.dart';
import '../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            AppLocalizations.getText(provider.languageCode, 'settings'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Google Account Sign-In / Cloud Sync Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Google Drive & Sheets Backup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.isSignedIn
                        ? 'Connected: ${provider.userEmail}'
                        : 'Sign in with Google to auto-sync your ledger to your personal Google Drive spreadsheet.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  provider.isSignedIn
                      ? OutlinedButton.icon(
                    onPressed: () => provider.signOutGoogle(),
                    icon: const Icon(Icons.logout, color: AppTheme.alertRed),
                    label: const Text('Sign Out from Google', style: TextStyle(color: AppTheme.alertRed)),
                  )
                      : ElevatedButton.icon(
                    onPressed: () async {
                      final success = await provider.signInWithGoogle();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Sign-In failed or was cancelled.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In with Google'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Modern Animated View Toggle Switch
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Modern Animated View', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: const Text('Enable smooth animations across UI layouts'),
              value: provider.modernView,
              onChanged: (val) => provider.toggleModernView(val),
            ),
          ),
          const SizedBox(height: 12),
          // Language Selection (English / Urdu with Gulzar font)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: Text(
                provider.isUrdu ? 'زبان: اردو (گلزار فونٹ)' : 'Language: English',
                style: TextStyle(fontFamily: provider.isUrdu ? 'Gulzar' : 'Roboto', fontSize: 16),
              ),
              subtitle: const Text('Switch between English and Urdu'),
              value: provider.isUrdu,
              onChanged: (isUrduVal) {
                provider.setLanguage(isUrduVal ? 'ur' : 'en');
              },
            ),
          ),
          const SizedBox(height: 12),
          // Notification Setting for Late Payments (>7 days)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Late Payment Notifications'),
              subtitle: const Text('Show alerts for customer payments delayed over 7 days'),
              value: provider.notificationsEnabled,
              onChanged: (val) => provider.toggleNotifications(val),
            ),
          ),
          const SizedBox(height: 12),
          // User Guide
          ExpansionTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
            title: const Text('User Guide & How To Use', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.getText(provider.languageCode, 'user_guide'),
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Data Privacy Assurance
          ExpansionTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Data Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.getText(provider.languageCode, 'privacy_policy'),
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}