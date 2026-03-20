import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String activeFilter = 'tous';
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filters = [
      _Filter('tous', appProvider.translate('Tous', 'All')),
      _Filter('randonnee', appProvider.translate('Randonnée', 'Hiking')),
      _Filter('camping', appProvider.translate('Camping', 'Camping')),
      _Filter('vtt', appProvider.translate('VTT', 'MTB')),
      _Filter('kayak', appProvider.translate('Kayak', 'Kayak')),
    ];

    final events = [
      _Event(1, appProvider.translate('Randonnée au Mont Blanc', 'Mont Blanc Hike'), '15 Décembre 2024', 'Chamonix, France', 45, 24, 30, 'randonnee'),
      _Event(2, appProvider.translate('Kayak en Ardèche', 'Kayaking in Ardèche'), '20 Décembre 2024', 'Ardèche, France', 65, 12, 20, 'kayak'),
      _Event(3, appProvider.translate('VTT en Forêt', 'Mountain Biking in the Forest'), '18 Décembre 2024', 'Fontainebleau, France', 35, 18, 25, 'vtt'),
      _Event(4, appProvider.translate('Camping Sauvage Pyrénées', 'Wild Camping Pyrénées'), '25 Décembre 2024', 'Pyrénées, France', 55, 20, 30, 'camping'),
    ];

    final list = activeFilter == 'tous' ? events : events.where((e) => e.category == activeFilter).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    final active = activeFilter == f.id;
                    return GestureDetector(
                      onTap: () => setState(() => activeFilter = f.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? kPrimary : (isDark ? kDarkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: active ? const [BoxShadow(color: Colors.black12, blurRadius: 6)] : null,
                        ),
                        child: Text(f.label, style: TextStyle(color: active ? Colors.white : (isDark ? kDarkText : Colors.grey.shade700))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: list.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.hardEdge,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.map_pin, color: Colors.white, size: 40),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title, style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(e.date, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.map_pin, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(e.location, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.users, size: 14, color: kPrimary),
                                      const SizedBox(width: 6),
                                      Text('${e.participants}/${e.maxParticipants}', style: const TextStyle(color: kPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${e.price}€', style: const TextStyle(color: kPrimary, fontSize: 18)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.green.shade100.withOpacity(isDark ? 0.2 : 1.0), borderRadius: BorderRadius.circular(20)),
                                        child: Text(
                                          appProvider.translate('Disponible', 'Available'),
                                          style: TextStyle(color: isDark ? Colors.green.shade400 : Colors.green.shade700, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Filter {
  final String id;
  final String label;
  _Filter(this.id, this.label);
}

class _Event {
  final int id;
  final String title;
  final String date;
  final String location;
  final int price;
  final int participants;
  final int maxParticipants;
  final String category;
  _Event(this.id, this.title, this.date, this.location, this.price, this.participants, this.maxParticipants, this.category);
}
