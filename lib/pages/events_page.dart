import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';

class _Filter {
  final String id;
  final String label;
  _Filter(this.id, this.label);
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String activeFilter = 'tous';
  List<dynamic> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    
    if (token != null) {
      final fetchedEvents = await ApiService.getEvents(token);
      if (mounted) {
        setState(() {
          events = fetchedEvents;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      _Filter('tous', 'Tous'),
      _Filter('randonnee', 'Randonnée'),
      _Filter('escalade', 'Escalade'),
      _Filter('vtt', 'VTT'),
      _Filter('camping', 'Camping'),
    ];
    
    final list = activeFilter == 'tous' 
        ? events 
        : events.where((e) => e['type']?.toString().toLowerCase() == activeFilter).toList();
    return Container(
      color: kLight,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : ListView(
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
                if (list.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(LucideIcons.calendar_x, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucun événement trouvé', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ...list.map((e) {
                    final eventDate = e['eventDate'] != null 
                        ? DateTime.parse(e['eventDate']).toString().split(' ')[0]
                        : 'Date inconnue';
                    final participants = e['participants'] as List? ?? [];
                    final capacity = e['capacity'] ?? 0;
                    
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
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                                borderRadius: const BorderRadius.all(Radius.circular(14)),
                                image: e['coverImage'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(e['coverImage']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: e['coverImage'] == null
                                  ? const Icon(LucideIcons.map_pin, color: Colors.white, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e['title'] ?? 'Sans titre', style: const TextStyle(color: kDark, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(eventDate, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.map_pin, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(e['locationName'] ?? 'Lieu inconnu', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.users, size: 14, color: kPrimary),
                                      const SizedBox(width: 6),
                                      Text('${participants.length}/$capacity participants', style: const TextStyle(color: kPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                    child: Text(e['type'] ?? 'Autre', style: const TextStyle(color: kPrimary, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
