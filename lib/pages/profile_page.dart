import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badges = [
      _Badge(appProvider.translate('Premier pas', 'First Step'), '🏃', true),
      _Badge(appProvider.translate('Aventurier', 'Adventurer'), '⛰️', true),
      _Badge(appProvider.translate('Explorateur', 'Explorer'), '🧭', true),
      _Badge(appProvider.translate('Champion', 'Champion'), '🏆', false),
      _Badge(appProvider.translate('Légende', 'Legend'), '⭐', false),
    ];
    final activities = [
      _Activity(appProvider.translate('Randonnée Mont Blanc', 'Mont Blanc Hike'), appProvider.translate('Il y a 2 jours', '2 days ago'), appProvider.translate('Complété', 'Completed'), 50),
      _Activity(appProvider.translate('VTT en Forêt', 'MTB in Forest'), appProvider.translate('Il y a 5 jours', '5 days ago'), appProvider.translate('Complété', 'Completed'), 30),
      _Activity(appProvider.translate('Kayak en Ardèche', 'Kayaking in Ardèche'), appProvider.translate('Il y a 1 semaine', '1 week ago'), appProvider.translate('Annulé', 'Cancelled'), 0),
    ];

    return Container(
      color: isDark ? kDarkBg : kLight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          AppCard(
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('MD', style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                    const SizedBox(height: 12),
                    Text('Marie Dubois', style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('marie.dubois@email.com', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 2),
                    const Text('+33 6 12 34 56 78', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.trophy, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appProvider.translate('Points totaux', 'Total Points'), style: const TextStyle(color: Colors.white70)),
                                  const Text('1,240', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(appProvider.translate('Niveau', 'Level'), style: const TextStyle(color: Colors.white70)),
                              Row(
                                children: const [
                                  Icon(LucideIcons.star, color: Colors.white, size: 18),
                                  SizedBox(width: 4),
                                  Text('8', style: TextStyle(color: Colors.white, fontSize: 22)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 12,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(appProvider.translate('760 points pour le niveau 9', '760 points to level 9'), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: ButtonVariant.outline,
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.settings, size: 18),
                            const SizedBox(width: 8),
                            Text(appProvider.translate('Paramètres', 'Settings')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.calendar, size: 18),
                            const SizedBox(width: 8),
                            Text(appProvider.translate('Historique', 'History')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(appProvider.translate('Badges & Réalisations', 'Badges & Achievements'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          AppCard(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final b = badges[i];
                final bg = b.earned ? kPrimary.withOpacity(0.2) : (isDark ? Colors.white12 : Colors.grey.shade300);
                final textColor = b.earned ? (isDark ? kDarkText : kDark) : Colors.grey;
                return Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(b.icon, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 4),
                    Text(b.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textColor)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(appProvider.translate('Activités récentes', 'Recent Activities'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Column(
            children: activities.map((a) {
              final ok = a.status == appProvider.translate('Complété', 'Completed');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ok ? Colors.green.shade100.withOpacity(isDark ? 0.2 : 1.0) : Colors.red.shade100.withOpacity(isDark ? 0.2 : 1.0),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(ok ? LucideIcons.award : LucideIcons.map_pin, color: ok ? (isDark ? Colors.green.shade400 : Colors.green.shade600) : (isDark ? Colors.red.shade400 : Colors.red.shade600)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: TextStyle(color: isDark ? kDarkText : kDark, fontWeight: FontWeight.w600)),
                              Text(a.date, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: ok ? Colors.green.shade100.withOpacity(isDark ? 0.2 : 1.0) : Colors.red.shade100.withOpacity(isDark ? 0.2 : 1.0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(a.status, style: TextStyle(color: ok ? (isDark ? Colors.green.shade400 : Colors.green.shade700) : (isDark ? Colors.red.shade400 : Colors.red.shade700))),
                          ),
                          if (a.points > 0)
                            const SizedBox(height: 4),
                          if (a.points > 0)
                            Text('+${a.points} pts', style: const TextStyle(color: kPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          AppButton(
            variant: ButtonVariant.outline,
            fullWidth: true,
            onPressed: () => appProvider.logout(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.log_out, size: 18),
                const SizedBox(width: 8),
                Text(appProvider.translate('Déconnexion', 'Logout')),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _Badge {
  final String name;
  final String icon;
  final bool earned;
  _Badge(this.name, this.icon, this.earned);
}

class _Activity {
  final String title;
  final String date;
  final String status;
  final int points;
  _Activity(this.title, this.date, this.status, this.points);
}
