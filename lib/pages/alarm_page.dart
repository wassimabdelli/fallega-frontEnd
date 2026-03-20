import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});
  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  bool showCreate = false;
  String selectedEvent = '';
  String date = '';
  String time = '';
  String notificationType = 'push';

  final upcomingEvents = const [
    {'id': 1, 'title': 'Randonnée Mont Blanc', 'date': '15 Décembre 2024'},
    {'id': 2, 'title': 'VTT en Forêt', 'date': '18 Décembre 2024'},
    {'id': 3, 'title': 'Kayak en Ardèche', 'date': '20 Décembre 2024'},
  ];

  final alarms = [
    {'id': 1, 'event': 'Randonnée Mont Blanc', 'date': '15 Décembre 2024', 'time': '06:00', 'type': 'push', 'active': true},
    {'id': 2, 'event': 'VTT en Forêt', 'date': '18 Décembre 2024', 'time': '13:00', 'type': 'sms', 'active': true},
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (showCreate) {
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appProvider.translate('Configurer le rappel', 'Configure Reminder'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appProvider.translate('Événement', 'Event'), style: TextStyle(color: isDark ? kDarkText : kDark)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedEvent.isEmpty ? null : selectedEvent,
                            dropdownColor: isDark ? kDarkSurface : Colors.white,
                            style: TextStyle(color: isDark ? kDarkText : kDark),
                            items: [
                              DropdownMenuItem(value: '', child: Text(appProvider.translate('Sélectionner un événement', 'Select an event'))),
                              ...upcomingEvents.map((e) => DropdownMenuItem(
                                    value: e['title'] as String,
                                    child: Text('${e['title']} - ${e['date']}'),
                                  )),
                            ],
                            onChanged: (v) => setState(() => selectedEvent = v ?? ''),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? kDarkSurface : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimary, width: 2)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: appProvider.translate('Date du rappel', 'Reminder Date'),
                        isDark: isDark,
                        child: TextField(
                          onChanged: (v) => date = v,
                          style: TextStyle(color: isDark ? kDarkText : kDark),
                          decoration: InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                            filled: true,
                            fillColor: isDark ? kDarkSurface : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimary, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: appProvider.translate('Heure du rappel', 'Reminder Time'),
                        isDark: isDark,
                        child: TextField(
                          onChanged: (v) => time = v,
                          style: TextStyle(color: isDark ? kDarkText : kDark),
                          decoration: InputDecoration(
                            hintText: 'HH:MM',
                            hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                            filled: true,
                            fillColor: isDark ? kDarkSurface : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimary, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(appProvider.translate('Type de notification', 'Notification Type'), style: TextStyle(color: isDark ? kDarkText : kDark)),
                      const SizedBox(height: 6),
                      Column(
                        children: [
                          _RadioTile(
                            title: appProvider.translate('Notification Push', 'Push Notification'),
                            subtitle: appProvider.translate('Alerte dans l\'application', 'App alert'),
                            value: 'push',
                            groupValue: notificationType,
                            isDark: isDark,
                            onChanged: (v) => setState(() => notificationType = v ?? 'push'),
                          ),
                          const SizedBox(height: 6),
                          _RadioTile(
                            title: 'SMS',
                            subtitle: appProvider.translate('Message texte', 'Text message'),
                            value: 'sms',
                            groupValue: notificationType,
                            isDark: isDark,
                            onChanged: (v) => setState(() => notificationType = v ?? 'sms'),
                          ),
                          const SizedBox(height: 6),
                          _RadioTile(
                            title: 'Push + SMS',
                            subtitle: appProvider.translate('Les deux notifications', 'Both notifications'),
                            value: 'both',
                            groupValue: notificationType,
                            isDark: isDark,
                            onChanged: (v) => setState(() => notificationType = v ?? 'both'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: ButtonVariant.outline,
                        onPressed: () => setState(() => showCreate = false),
                        child: Text(appProvider.translate('Annuler', 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        onPressed: () => setState(() => showCreate = false),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.alarm_clock, size: 20),
                            const SizedBox(width: 8),
                            Text(appProvider.translate('Créer le rappel', 'Create Reminder')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    final activeCount = alarms.where((a) => a['active'] == true).length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              AppCard(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(LucideIcons.alarm_clock, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appProvider.translate('Rappels actifs', 'Active Reminders'), style: const TextStyle(color: Colors.white)),
                          Text(appProvider.translate('$activeCount rappels configurés', '$activeCount reminders configured'), style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                fullWidth: true,
                onPressed: () => setState(() => showCreate = true),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.plus, size: 20), const SizedBox(width: 8), Text(appProvider.translate('Nouveau rappel', 'New Reminder'))]),
              ),
              const SizedBox(height: 16),
              Text(appProvider.translate('Mes rappels', 'My Reminders'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Column(
                children: alarms.map((alarm) {
                  final type = alarm['type'] as String;
                  final active = alarm['active'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Icon(LucideIcons.bell, color: kPrimary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alarm['event'] as String, style: TextStyle(color: isDark ? kDarkText : kDark, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(alarm['date'] as String, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.alarm_clock, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(alarm['time'] as String, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _Badge(
                                      text: type == 'push' ? 'Push' : type == 'sms' ? 'SMS' : 'Push + SMS',
                                      color: Colors.blue,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 6),
                                    _Badge(
                                      text: active ? appProvider.translate('Actif', 'Active') : appProvider.translate('Inactif', 'Inactive'),
                                      color: active ? Colors.green : Colors.grey,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                                        alignment: Alignment.center,
                                        child: Text(active ? appProvider.translate('Désactiver', 'Deactivate') : appProvider.translate('Activer', 'Activate'), style: TextStyle(color: isDark ? kDarkText : kDark)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(LucideIcons.trash_2, color: Colors.red, size: 18),
                                    ),
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

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isDark;
  const _LabeledField({required this.label, required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? kDarkText : kDark)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final bool isDark;
  final ValueChanged<String?> onChanged;
  const _RadioTile({required this.title, required this.subtitle, required this.value, required this.groupValue, required this.isDark, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final active = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? kPrimary : (isDark ? Colors.white12 : Colors.black12), width: 2),
        ),
        child: Row(
          children: [
            Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged, activeColor: kPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? kDarkText : kDark)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final MaterialColor color;
  final bool isDark;
  const _Badge({required this.text, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.shade100.withOpacity(isDark ? 0.2 : 1.0), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: isDark ? color.shade300 : color.shade700, fontSize: 12)),
    );
  }
}

void _noop(int _) {}
