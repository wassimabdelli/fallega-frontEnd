import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final posts = [
      _Post(
        id: 1,
        author: 'Marie Dubois',
        avatar: 'MD',
        time: appProvider.translate('Il y a 2 heures', '2 hours ago'),
        title: appProvider.translate('Randonnée au Mont Blanc', 'Mont Blanc Hike'),
        description: appProvider.translate(
          'Une magnifique randonnée en montagne pour découvrir les Alpes. Niveau intermédiaire, équipement fourni.',
          'A beautiful mountain hike to discover the Alps. Intermediate level, equipment provided.',
        ),
        date: '15 Décembre 2024',
        location: 'Chamonix, France',
        participants: 24,
        maxParticipants: 30,
        likes: 45,
        comments: 12,
      ),
      _Post(
        id: 2,
        author: 'Jean Martin',
        avatar: 'JM',
        time: appProvider.translate('Il y a 5 heures', '5 hours ago'),
        title: appProvider.translate('Kayak en Ardèche', 'Kayaking in Ardèche'),
        description: appProvider.translate(
          'Descente de l\'Ardèche en kayak sur 2 jours avec camping. Une aventure inoubliable en pleine nature.',
          'Kayaking down the Ardèche over 2 days with camping. An unforgettable adventure in the heart of nature.',
        ),
        date: '20 Décembre 2024',
        location: 'Ardèche, France',
        participants: 12,
        maxParticipants: 20,
        likes: 32,
        comments: 8,
      ),
      _Post(
        id: 3,
        author: 'Sophie Blanc',
        avatar: 'SB',
        time: appProvider.translate('Hier', 'Yesterday'),
        title: appProvider.translate('VTT en Forêt de Fontainebleau', 'Mountain Biking in Fontainebleau Forest'),
        description: appProvider.translate(
          'Parcours VTT pour tous niveaux dans la magnifique forêt de Fontainebleau. Vélos disponibles sur place.',
          'Mountain bike trails for all levels in the beautiful Fontainebleau forest. Bikes available on site.',
        ),
        date: '18 Décembre 2024',
        location: 'Fontainebleau, France',
        participants: 18,
        maxParticipants: 25,
        likes: 28,
        comments: 6,
      ),
    ];

    return Container(
      color: isDark ? kDarkBg : kLight,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemBuilder: (_, i) {
          final p = posts[i];
          return AppCard(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(p.avatar, style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.author, style: TextStyle(color: isDark ? kDarkText : kDark, fontWeight: FontWeight.w600)),
                            Text(p.time, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                  ),
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.map_pin, color: Colors.white.withOpacity(0.3), size: 72),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(p.description, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.left),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 18, color: kPrimary),
                              const SizedBox(width: 6),
                              Text(p.date, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(LucideIcons.map_pin, size: 18, color: kPrimary),
                              const SizedBox(width: 6),
                              Text(p.location, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(LucideIcons.users, size: 18, color: kPrimary),
                              const SizedBox(width: 6),
                              Text('${p.participants}/${p.maxParticipants} ${appProvider.translate('participants', 'participants')}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(LucideIcons.heart, color: Colors.grey),
                              label: Text('${p.likes}', style: const TextStyle(color: Colors.grey)),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(LucideIcons.message_square, color: Colors.grey),
                              label: Text('${p.comments}', style: const TextStyle(color: Colors.grey)),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(LucideIcons.share_2, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              variant: ButtonVariant.outline,
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.map_pin, size: 18),
                                  const SizedBox(width: 8),
                                  Text(appProvider.translate('Voir sur la carte', 'View on map')),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              onPressed: () {},
                              child: Text(appProvider.translate('Participer', 'Join')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: posts.length,
      ),
    );
  }
}

class _Post {
  final int id;
  final String author;
  final String avatar;
  final String time;
  final String title;
  final String description;
  final String date;
  final String location;
  final int participants;
  final int maxParticipants;
  final int likes;
  final int comments;
  _Post({
    required this.id,
    required this.author,
    required this.avatar,
    required this.time,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.participants,
    required this.maxParticipants,
    required this.likes,
    required this.comments,
  });
}
