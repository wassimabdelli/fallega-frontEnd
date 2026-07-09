import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showSearch;
  final String userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;
  const AppHeader({
    super.key,
    required this.title,
    this.showSearch = true,
    this.userAvatar = 'MD',
    this.onProfileTap,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onBackTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onBackTap != null)
                  IconButton(
                    onPressed: onBackTap,
                    icon: Icon(LucideIcons.chevron_left, color: isDark ? kDarkText : kDark),
                  )
                else
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userAvatar,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (onBackTap != null)
                  const SizedBox(width: 48) // Balances the back button
                else
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: onNotificationsTap,
                            icon: Icon(LucideIcons.bell, color: isDark ? kDarkText : kDark, size: 22),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: onSettingsTap,
                        icon: Icon(LucideIcons.settings, color: isDark ? kDarkText : kDark, size: 22),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              style: TextStyle(color: isDark ? kDarkText : kDark),
              onChanged: (val) => context.read<AppProvider>().setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                prefixIcon: Icon(LucideIcons.search, color: isDark ? Colors.grey : Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: isDark ? kDarkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: kPrimary, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
