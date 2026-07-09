import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _searchResults = [];
  Map<String, bool> _friendshipStatus = {};
  Map<String, bool> _pendingInvitations = {};
  Map<String, bool> _invitationSent = {};
  bool _isLoading = false;
  String _lastQuery = '';
  Timer? _debounce;

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _lastQuery = '';
        _friendshipStatus = {};
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _lastQuery = query;
    });

    final results = await ApiService.searchUsers(query);
    
    if (mounted && query == _lastQuery) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      _checkFriendships(results);
    }
  }

  Future<void> _checkFriendships(List<dynamic> users) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final token = appProvider.token;

    if (currentUser == null || token == null) return;

    for (var user in users) {
      final targetId = user['_id'];
      if (targetId == currentUser['_id']) continue;

      final isFriend = await ApiService.isFriend(currentUser['_id'], targetId, token);
      if (mounted) {
        setState(() {
          _friendshipStatus[targetId] = isFriend;
        });
      }
    }
  }

  Future<void> _sendInvitation(String receiverId) async {
    if (_pendingInvitations[receiverId] == true) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    final currentUser = appProvider.user;

    if (token == null || currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appProvider.translate('Veuillez vous reconnecter.', 'Please log in again.'))),
        );
      }
      return;
    }

    setState(() {
      _pendingInvitations[receiverId] = true;
    });

    // 1. Envoyer l'invitation
    final result = await ApiService.sendInvitation(receiverId, token);
    
    if (result['_id'] != null || result['status'] == 'PENDING') {
      // 2. Créer une notification pour l'utilisateur B
      await ApiService.createNotification({
        'type': 'INVITATION',
        'title': 'Nouvelle invitation',
        'body': '${currentUser['prenom']} ${currentUser['nom']} vous a envoyé une invitation.',
        'user': receiverId,
      }, token);

      if (mounted) {
        setState(() {
          _pendingInvitations[receiverId] = false;
          _invitationSent[receiverId] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appProvider.translate('Invitation envoyée !', 'Invitation sent!'))),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _pendingInvitations[receiverId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur lors de l\'envoi')),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = appProvider.searchQuery;
    final currentUser = appProvider.user;

    // Trigger search when query changes, but outside of the build phase
    if (query != _lastQuery && !_isLoading) {
      _lastQuery = query; // Update immediately to prevent multiple calls
      Future.microtask(() => _onQueryChanged(query));
    }

    if (query.isNotEmpty) {
      return Container(
        color: isDark ? kDarkBg : kLight,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _searchResults.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.search_x, size: 64, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      appProvider.translate('Aucun utilisateur trouvé', 'No users found'),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final user = _searchResults[i];
                  final userId = user['_id'];
                  final name = '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim();
                  final initials = (user['prenom']?.isNotEmpty == true ? user['prenom'][0] : '') + 
                                   (user['nom']?.isNotEmpty == true ? user['nom'][0] : '');
                  
                  final isMe = currentUser != null && userId == currentUser['_id'];
                  final isFriend = _friendshipStatus[userId] ?? false;

                  return AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: isDark ? kDarkText : kDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user['email'] ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        if (!isMe && !isFriend)
                          _pendingInvitations[userId] == true
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
                              )
                            : _invitationSent[userId] == true
                                ? AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(LucideIcons.clock, color: Colors.orange, size: 20),
                                  )
                                : IconButton(
                                    onPressed: () => _sendInvitation(userId),
                                    icon: const Icon(LucideIcons.user_plus, color: kPrimary),
                                    tooltip: appProvider.translate('Ajouter en ami', 'Add friend'),
                                  )
                        else if (isFriend)
                          const Icon(LucideIcons.check, color: Colors.green, size: 20),
                        
                        if (user['role'] != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user['role'].toString().toUpperCase(),
                              style: const TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      );
    }

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
