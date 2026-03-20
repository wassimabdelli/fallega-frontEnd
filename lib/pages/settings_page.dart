import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.themeMode == ThemeMode.dark;
    final currentLang = appProvider.locale.languageCode;

    final settingsSections = [
      {
        'title': appProvider.translate('Compte', 'Account'),
        'items': [
          {'icon': LucideIcons.user, 'label': appProvider.translate('Informations personnelles', 'Personal Information'), 'onTap': () {}},
          {'icon': LucideIcons.lock, 'label': appProvider.translate('Mot de passe', 'Password'), 'onTap': () {}},
          {'icon': LucideIcons.shield, 'label': appProvider.translate('Confidentialité', 'Privacy'), 'onTap': () {}},
        ],
      },
      {
        'title': appProvider.translate('Préférences', 'Preferences'),
        'items': [
          {
            'icon': LucideIcons.bell,
            'label': 'Notifications',
            'toggle': true,
            'value': true, // Static for now
            'onChanged': (bool v) {},
          },
          {
            'icon': LucideIcons.moon,
            'label': appProvider.translate('Mode sombre', 'Dark Mode'),
            'toggle': true,
            'value': isDark,
            'onChanged': (bool v) => appProvider.toggleTheme(v),
          },
          {
            'icon': LucideIcons.globe,
            'label': appProvider.translate('Langue', 'Language'),
            'subtitle': currentLang == 'fr' ? 'Français' : 'English',
            'onTap': () {
              _showLanguageDialog(context, appProvider);
            }
          },
        ],
      },
      {
        'title': 'Support',
        'items': [
          {'icon': LucideIcons.info, 'label': appProvider.translate('Centre d\'aide', 'Help Center'), 'onTap': () {}},
          {'icon': LucideIcons.shield, 'label': appProvider.translate('Conditions d\'utilisation', 'Terms of Use'), 'onTap': () {}},
          {'icon': LucideIcons.shield, 'label': appProvider.translate('Politique de confidentialité', 'Privacy Policy'), 'onTap': () {}},
        ],
      },
      {
        'title': appProvider.translate('Session', 'Session'),
        'items': [
          {
            'icon': LucideIcons.log_out,
            'label': appProvider.translate('Déconnexion', 'Logout'),
            'onTap': () => appProvider.logout(),
          },
        ],
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: settingsSections.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (_, i) {
        if (i == settingsSections.length) {
          return AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(appProvider.translate('Version', 'Version'), style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                const Text('Fallega 1.0.0', style: TextStyle(color: kDark, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        final section = settingsSections[i];
        final items = section['items'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section['title'] as String,
              style: const TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, j) {
                final item = items[j];
                final isToggle = item['toggle'] == true;

                return AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: isToggle ? null : item['onTap'] as VoidCallback,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(item['icon'] as IconData, color: kPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['label'] as String, style: const TextStyle(color: kDark, fontWeight: FontWeight.w500)),
                            if (item.containsKey('subtitle'))
                              Text(item['subtitle'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (isToggle)
                        Switch(
                          value: item['value'] as bool,
                          onChanged: item['onChanged'] as ValueChanged<bool>,
                          activeColor: kPrimary,
                        )
                      else
                        const Icon(LucideIcons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.translate('Choisir la langue', 'Select Language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: Radio<String>(
                value: 'fr',
                groupValue: provider.locale.languageCode,
                onChanged: (v) {
                  provider.setLocale('fr');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                provider.setLocale('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: provider.locale.languageCode,
                onChanged: (v) {
                  provider.setLocale('en');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                provider.setLocale('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
