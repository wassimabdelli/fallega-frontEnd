import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const AppBottomNav({super.key, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(LucideIcons.house, appProvider.translate('Dashboard', 'Dashboard')),
      _NavItem(LucideIcons.shopping_bag, appProvider.translate('Marketplace', 'Marketplace')),
      _NavItem(LucideIcons.calendar, appProvider.translate('Calendrier', 'Calendar')),
      _NavItem(LucideIcons.message_square, appProvider.translate('Chat', 'Chat')),
      _NavItem(LucideIcons.alarm_clock, appProvider.translate('Réveil', 'Alarm')),
      _NavItem(LucideIcons.user, appProvider.translate('Profil', 'Profile')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = selectedIndex == i;
            final color = active ? kPrimary : Colors.grey;
            return InkWell(
              onTap: () => onSelected(i),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, size: 20, color: color),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: TextStyle(fontSize: 10, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}
