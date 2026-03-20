import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../main.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String activeFilter = 'tous';
  @override
  Widget build(BuildContext context) {
    final filters = [
      _Filter('tous', 'Tous'),
      _Filter('randonnee', 'Randonnée'),
      _Filter('escalade', 'Escalade'),
      _Filter('vtt', 'VTT'),
      _Filter('camping', 'Camping'),
    ];
    final events = [
      _Event(1, 'Randonnée Mont Blanc', '15 Déc 2024', 'Chamonix', 24, 'Difficile', 'randonnee'),
      _Event(2, 'Kayak en Ardèche', '20 Déc 2024', 'Ardèche', 12, 'Moyen', 'autres'),
      _Event(3, 'Escalade Fontainebleau', '22 Déc 2024', 'Fontainebleau', 18, 'Facile', 'escalade'),
      _Event(4, 'VTT en Forêt', '18 Déc 2024', 'Forêt de Rambouillet', 15, 'Moyen', 'vtt'),
      _Event(5, 'Camping Sauvage', '25 Déc 2024', 'Pyrénées', 20, 'Difficile', 'camping'),
      _Event(6, 'Trail Running', '28 Déc 2024', 'Chamonix', 30, 'Difficile', 'randonnee'),
    ];
    final list = activeFilter == 'tous' ? events : events.where((e) => e.category == activeFilter).toList();
    return Container(
      color: kLight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un événement...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(LucideIcons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
                final active = activeFilter == f.id;
                final bg = active ? kPrimary : Colors.white;
                final fg = active ? Colors.white : Colors.grey.shade700;
                return GestureDetector(
                  onTap: () => setState(() => activeFilter = f.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: active ? const [BoxShadow(color: Colors.black12, blurRadius: 6)] : null,
                    ),
                    child: Text(f.label, style: TextStyle(color: fg)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ...list.map((e) {
            final diffColor = switch (e.difficulty) {
              'Facile' => Colors.green,
              'Moyen' => Colors.yellow,
              _ => Colors.red,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.map_pin, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: const TextStyle(color: kDark, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(e.date, style: const TextStyle(color: Colors.grey)),
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
                              Text('${e.participants} participants', style: const TextStyle(color: kPrimary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: diffColor.shade100, borderRadius: BorderRadius.circular(20)),
                            child: Text(e.difficulty, style: TextStyle(color: diffColor.shade700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          AppButton(onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.plus, size: 18), SizedBox(width: 8), Text('Créer un événement')])),
        ],
      ),
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
  final int participants;
  final String difficulty;
  final String category;
  _Event(this.id, this.title, this.date, this.location, this.participants, this.difficulty, this.category);
}
