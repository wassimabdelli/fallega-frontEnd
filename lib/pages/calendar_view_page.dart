import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({super.key});
  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  int currentYear = 2024;
  int? selectedMonth;
  String? selectedDate;

  final events = const [
    {'id': 1, 'date': '2024-12-15', 'title': 'Randonnée Mont Blanc', 'location': 'Chamonix'},
    {'id': 2, 'date': '2024-12-18', 'title': 'VTT en Forêt', 'location': 'Fontainebleau'},
    {'id': 3, 'date': '2024-12-20', 'title': 'Kayak en Ardèche', 'location': 'Ardèche'},
    {'id': 4, 'date': '2024-12-25', 'title': 'Camping Pyrénées', 'location': 'Pyrénées'},
  ];

  bool hasEvent(int monthIndex) {
    return events.any((e) {
      final d = DateTime.parse(e['date'] as String);
      return d.month == monthIndex + 1 && d.year == currentYear;
    });
  }

  List<int?> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1).weekday % 7; // 0=Dim
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final days = <int?>[];
    for (int i = 0; i < firstDay; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }
    return days;
  }

  List<Map<String, Object>> getEventsForDate(int day) {
    if (selectedMonth == null) return [];
    final dateStr = '${currentYear}-${(selectedMonth! + 1).toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return events.where((e) => e['date'] == dateStr).toList();
  }

  bool hasEventOnDay(int day) => getEventsForDate(day).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final months = [
      appProvider.translate('Janvier', 'January'),
      appProvider.translate('Février', 'February'),
      appProvider.translate('Mars', 'March'),
      appProvider.translate('Avril', 'April'),
      appProvider.translate('Mai', 'May'),
      appProvider.translate('Juin', 'June'),
      appProvider.translate('Juillet', 'July'),
      appProvider.translate('Août', 'August'),
      appProvider.translate('Septembre', 'September'),
      appProvider.translate('Octobre', 'October'),
      appProvider.translate('Novembre', 'November'),
      appProvider.translate('Décembre', 'December')
    ];

    if (selectedMonth == null) {
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () => setState(() => currentYear--), icon: Icon(LucideIcons.chevron_left, color: isDark ? kDarkText : kDark)),
                    Text('$currentYear', style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(onPressed: () => setState(() => currentYear++), icon: Icon(LucideIcons.chevron_right, color: isDark ? kDarkText : kDark)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: months.length,
                  itemBuilder: (_, i) {
                    final month = months[i];
                    final dot = hasEvent(i);
                    return AppCard(
                      onTap: () => setState(() => selectedMonth = i),
                      child: Stack(
                        children: [
                          Center(child: Text(month, style: TextStyle(color: isDark ? kDarkText : kDark))),
                          if (dot)
                            const Positioned(
                              right: 8,
                              top: 8,
                              child: SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle))),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (selectedDate == null) {
      final days = getDaysInMonth(currentYear, selectedMonth! + 1);
      final dayNames = [
        appProvider.translate('Dim', 'Sun'),
        appProvider.translate('Lun', 'Mon'),
        appProvider.translate('Mar', 'Tue'),
        appProvider.translate('Mer', 'Wed'),
        appProvider.translate('Jeu', 'Thu'),
        appProvider.translate('Ven', 'Fri'),
        appProvider.translate('Sam', 'Sat')
      ];
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                TextButton(
                  onPressed: () => setState(() => selectedMonth = null),
                  child: Align(alignment: Alignment.centerLeft, child: Text(appProvider.translate('← Retour à l\'année', '← Back to year'), style: const TextStyle(color: kPrimary))),
                ),
                AppCard(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: dayNames.length,
                        itemBuilder: (_, i) => Center(child: Text(dayNames[i], style: const TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: days.length,
                        itemBuilder: (_, i) {
                          final d = days[i];
                          if (d == null) return const SizedBox.shrink();
                          final active = hasEventOnDay(d);
                          return GestureDetector(
                            onTap: active
                                ? () => setState(() => selectedDate = '${currentYear}-${(selectedMonth! + 1).toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}')
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: active ? kPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: active ? const [BoxShadow(color: Colors.black12, blurRadius: 6)] : null,
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '$d',
                                      style: TextStyle(color: active ? Colors.white : Colors.grey),
                                    ),
                                  ),
                                  if (active)
                                    const Positioned(
                                      bottom: 6,
                                      left: 0,
                                      right: 0,
                                      child: SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final dayEvents = events.where((e) => e['date'] == selectedDate).toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              TextButton(
                onPressed: () => setState(() => selectedDate = null),
                child: Align(alignment: Alignment.centerLeft, child: Text(appProvider.translate('← Retour au calendrier', '← Back to calendar'), style: const TextStyle(color: kPrimary))),
              ),
              Text(appProvider.translate('Événements du jour', 'Day\'s Events'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Column(
                children: dayEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      onTap: () {},
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 56,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Center(child: Icon(LucideIcons.calendar, color: Colors.white, size: 28)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['title'] as String, style: TextStyle(color: isDark ? kDarkText : kDark, fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.map_pin, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(event['location'] as String, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
