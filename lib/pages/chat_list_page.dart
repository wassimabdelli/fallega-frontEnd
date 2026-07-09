import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String activeTab = 'all';
  List<dynamic> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.user;
    final token = appProvider.token;

    if (currentUser == null || token == null) return;

    setState(() => _isLoading = true);

    try {
      final friendsData = await ApiService.getFriends(currentUser['_id'], token);
      if (mounted) {
        setState(() {
          _friends = friendsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = appProvider.user;

    // Filter logic if needed, for now we show all friends
    final filteredFriends = _friends;

    return Column(
      children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _buildTabButton(
                label: appProvider.translate('Tous', 'All'),
                icon: LucideIcons.users,
                isActive: activeTab == 'all',
                onTap: () => setState(() => activeTab = 'all'),
              ),
              const SizedBox(width: 12),
              _buildTabButton(
                label: appProvider.translate('Privés', 'Private'),
                icon: LucideIcons.user,
                isActive: activeTab == 'private',
                onTap: () => setState(() => activeTab = 'private'),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : filteredFriends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.users, size: 64, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        appProvider.translate('Aucun ami pour le moment', 'No friends yet'),
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filteredFriends.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final friendship = filteredFriends[index];
                    // Identify which user in the friendship is the friend (not the current user)
                    final friend = friendship['user1']['_id'] == currentUser?['_id'] 
                        ? friendship['user2'] 
                        : friendship['user1'];
                    
                    final friendName = '${friend['prenom'] ?? ''} ${friend['nom'] ?? ''}'.trim();
                    final initials = (friend['prenom']?.isNotEmpty == true ? friend['prenom'][0] : '') + 
                                     (friend['nom']?.isNotEmpty == true ? friend['nom'][0] : '');

                    return AppCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              chatId: friendship['_id'],
                              friendId: friend['_id'],
                              name: friendName,
                              avatar: initials.toUpperCase(),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [kPrimary, kPrimaryDark],
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      friendName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? kDarkText : kDark,
                                      ),
                                    ),
                                    // You can add last message time here if available
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  friend['email'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kPrimary : (Theme.of(context).brightness == Brightness.dark ? kDarkSurface : Colors.white),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
