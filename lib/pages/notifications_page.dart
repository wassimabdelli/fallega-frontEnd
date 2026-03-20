import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      {
        'id': 1,
        'type': 'event',
        'icon': LucideIcons.calendar,
        'title': appProvider.translate('Nouveau événement', 'New Event'),
        'message': appProvider.translate('Randonnée Mont Blanc commence dans 2 jours', 'Mont Blanc Hike starts in 2 days'),
        'time': appProvider.translate('Il y a 1h', '1h ago'),
        'unread': true,
      },
      {
        'id': 2,
        'type': 'message',
        'icon': LucideIcons.message_circle,
        'title': appProvider.translate('Nouveau message', 'New Message'),
        'message': appProvider.translate('Marie Dubois: On se retrouve à quelle heure ?', 'Marie Dubois: What time are we meeting?'),
        'time': appProvider.translate('Il y a 2h', '2h ago'),
        'unread': true,
      },
      {
        'id': 3,
        'type': 'like',
        'icon': LucideIcons.heart,
        'title': appProvider.translate('Nouveau like', 'New Like'),
        'message': appProvider.translate('Jean Martin a aimé votre événement', 'Jean Martin liked your event'),
        'time': appProvider.translate('Il y a 3h', '3h ago'),
        'unread': false,
      },
      {
        'id': 4,
        'type': 'booking',
        'icon': LucideIcons.users,
        'title': appProvider.translate('Nouvelle réservation', 'New Booking'),
        'message': appProvider.translate('Sophie Blanc s\'est inscrite à votre événement', 'Sophie Blanc joined your event'),
        'time': appProvider.translate('Il y a 5h', '5h ago'),
        'unread': false,
      },
      {
        'id': 5,
        'type': 'equipment',
        'icon': LucideIcons.map_pin,
        'title': appProvider.translate('Matériel disponible', 'Equipment Available'),
        'message': appProvider.translate('Le sac à dos 50L est maintenant disponible', 'The 50L backpack is now available'),
        'time': appProvider.translate('Hier', 'Yesterday'),
        'unread': false,
      },
      {
        'id': 6,
        'type': 'event',
        'icon': LucideIcons.calendar,
        'title': appProvider.translate('Événement annulé', 'Event Cancelled'),
        'message': appProvider.translate('Camping Sauvage a été annulé par l\'organisateur', 'Wild Camping has been cancelled by the organizer'),
        'time': appProvider.translate('Il y a 2 jours', '2 days ago'),
        'unread': false,
      },
    ];

    Color _getIconBgColor(String type) {
      switch (type) {
        case 'event': return Colors.blue.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'message': return Colors.green.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'like': return Colors.red.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'booking': return Colors.purple.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'equipment': return kPrimary.withOpacity(0.1);
        default: return Colors.grey.shade100.withOpacity(isDark ? 0.2 : 1.0);
      }
    }

    Color _getIconColor(String type) {
      switch (type) {
        case 'event': return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
        case 'message': return isDark ? Colors.green.shade300 : Colors.green.shade600;
        case 'like': return isDark ? Colors.red.shade300 : Colors.red.shade600;
        case 'booking': return isDark ? Colors.purple.shade300 : Colors.purple.shade600;
        case 'equipment': return kPrimary;
        default: return isDark ? Colors.grey.shade300 : Colors.grey.shade600;
      }
    }

    final filteredNotifications = filter == 'all' 
        ? notifications 
        : notifications.where((n) => n['unread'] == true).toList();
    
    final unreadCount = notifications.where((n) => n['unread'] == true).length;

    return Container(
      color: isDark ? kDarkBg : kLight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: filter == 'all' ? ButtonVariant.primary : ButtonVariant.secondary,
                        onPressed: () => setState(() => filter = 'all'),
                        child: Text('${appProvider.translate('Toutes', 'All')} (${notifications.length})'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        variant: filter == 'unread' ? ButtonVariant.primary : ButtonVariant.secondary,
                        onPressed: () => setState(() => filter = 'unread'),
                        child: Text('${appProvider.translate('Non lues', 'Unread')} ($unreadCount)'),
                      ),
                    ),
                  ],
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    variant: ButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.check, size: 20),
                        const SizedBox(width: 8),
                        Text(appProvider.translate('Tout marquer comme lu', 'Mark all as read')),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: filteredNotifications.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bell, size: 64, color: isDark ? Colors.white10 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(appProvider.translate('Aucune notification', 'No notifications'), style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                      Text(appProvider.translate('Vous êtes à jour !', 'You are all caught up!'), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filteredNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final n = filteredNotifications[i];
                    final isUnread = n['unread'] as bool;
                    return AppCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () {},
                      child: Container(
                        decoration: isUnread ? BoxDecoration(
                          border: Border.all(color: kPrimary.withOpacity(0.3), width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ) : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getIconBgColor(n['type'] as String),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(n['icon'] as IconData, color: _getIconColor(n['type'] as String), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(n['title'] as String, style: TextStyle(color: isDark ? kDarkText : kDark, fontWeight: FontWeight.w600)),
                                      if (isUnread)
                                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n['message'] as String, style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text(n['time'] as String, style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
