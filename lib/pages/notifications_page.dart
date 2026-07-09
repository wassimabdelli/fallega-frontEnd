import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'all';
  List<dynamic> _invitations = [];
  Map<String, String> _processedStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final token = appProvider.token;

    if (currentUser == null || token == null) return;

    setState(() => _isLoading = true);

    try {
      final invitations = await ApiService.getReceivedInvitations(currentUser['_id'], token);
      if (mounted) {
        setState(() {
          _invitations = invitations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleInvitation(String id, bool accept) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    if (token == null) return;

    final result = accept 
      ? await ApiService.acceptInvitation(id, token)
      : await ApiService.rejectInvitation(id, token);

    if (result['_id'] != null || result['status'] != null) {
      if (mounted) {
        setState(() {
          _processedStatus[id] = accept ? 'ACCEPTED' : 'REJECTED';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept 
            ? appProvider.translate('Invitation acceptée !', 'Invitation accepted!')
            : appProvider.translate('Invitation refusée.', 'Invitation rejected.'))),
        );
        // On ne recharge plus immédiatement pour voir l'effet
        // _fetchData(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fusionner les notifications statiques avec les invitations dynamiques
    final staticNotifications = [
      {
        'id': 's1',
        'type': 'event',
        'icon': LucideIcons.calendar,
        'title': appProvider.translate('Nouveau événement', 'New Event'),
        'message': appProvider.translate('Randonnée Mont Blanc commence dans 2 jours', 'Mont Blanc Hike starts in 2 days'),
        'time': appProvider.translate('Il y a 1h', '1h ago'),
        'unread': true,
      },
      {
        'id': 's2',
        'type': 'message',
        'icon': LucideIcons.message_circle,
        'title': appProvider.translate('Nouveau message', 'New Message'),
        'message': appProvider.translate('Marie Dubois: On se retrouve à quelle heure ?', 'Marie Dubois: What time are we meeting?'),
        'time': appProvider.translate('Il y a 2h', '2h ago'),
        'unread': true,
      },
    ];

    final dynamicInvitations = _invitations.map((inv) {
      final sender = inv['sender'];
      final senderName = sender != null ? '${sender['prenom']} ${sender['nom']}' : 'Utilisateur';
      return {
        'id': inv['_id'],
        'type': 'invitation',
        'icon': LucideIcons.user_plus,
        'title': appProvider.translate('Invitation d\'ami', 'Friend Invitation'),
        'message': appProvider.translate('$senderName vous a envoyé une invitation.', '$senderName sent you an invitation.'),
        'time': appProvider.translate('Nouveau', 'New'),
        'unread': inv['status'] == 'PENDING',
        'isInvitation': true,
      };
    }).toList();

    final allNotifications = [...dynamicInvitations, ...staticNotifications];

    Color _getIconBgColor(String type) {
      switch (type) {
        case 'event': return Colors.blue.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'message': return Colors.green.shade50.withOpacity(isDark ? 0.2 : 1.0);
        case 'invitation': return Colors.orange.shade50.withOpacity(isDark ? 0.2 : 1.0);
        default: return Colors.grey.shade100.withOpacity(isDark ? 0.2 : 1.0);
      }
    }

    Color _getIconColor(String type) {
      switch (type) {
        case 'event': return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
        case 'message': return isDark ? Colors.green.shade300 : Colors.green.shade600;
        case 'invitation': return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
        default: return isDark ? Colors.grey.shade300 : Colors.grey.shade600;
      }
    }

    final filteredNotifications = filter == 'all' 
        ? allNotifications 
        : allNotifications.where((n) => n['unread'] == true).toList();
    
    final unreadCount = allNotifications.where((n) => n['unread'] == true).length;

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
                        child: Text('${appProvider.translate('Toutes', 'All')} (${allNotifications.length})'),
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
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : filteredNotifications.isEmpty 
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
                      final isInv = n['isInvitation'] == true;

                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
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
                            if (isInv) ...[
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _processedStatus[n['id']] != null
                                  ? Container(
                                      key: ValueKey('status_${n['id']}'),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _processedStatus[n['id']] == 'ACCEPTED' 
                                            ? Colors.green.withOpacity(0.1) 
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _processedStatus[n['id']] == 'ACCEPTED' 
                                                ? LucideIcons.check 
                                                : LucideIcons.x,
                                            size: 16,
                                            color: _processedStatus[n['id']] == 'ACCEPTED' ? Colors.green : Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _processedStatus[n['id']] == 'ACCEPTED'
                                                ? appProvider.translate('Ami ajouté', 'Friend added')
                                                : appProvider.translate('Invitation refusée', 'Invitation declined'),
                                            style: TextStyle(
                                              color: _processedStatus[n['id']] == 'ACCEPTED' ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      key: ValueKey('actions_${n['id']}'),
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            variant: ButtonVariant.outline,
                                            onPressed: () => _handleInvitation(n['id'], false),
                                            child: Text(appProvider.translate('Refuser', 'Decline')),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: AppButton(
                                            onPressed: () => _handleInvitation(n['id'], true),
                                            child: Text(appProvider.translate('Accepter', 'Accept')),
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            ],
                          ],
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
