import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../services/api_service.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String activeFilter = 'tous';
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.token;
    
    if (token != null) {
      final fetchedProducts = await ApiService.getMarketplaceProducts(token);
      if (mounted) {
        setState(() {
          products = fetchedProducts;
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
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filters = [
      _Filter('tous', appProvider.translate('Tous', 'All')),
      _Filter('randonnee', appProvider.translate('Randonnée', 'Hiking')),
      _Filter('camping', appProvider.translate('Camping', 'Camping')),
      _Filter('vtt', appProvider.translate('VTT', 'MTB')),
      _Filter('kayak', appProvider.translate('Kayak', 'Kayak')),
    ];
    
    final list = activeFilter == 'tous' 
        ? products 
        : products.where((p) => p['category']?['name']?.toString().toLowerCase() == activeFilter).toList();

    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = filters[i];
                          final active = activeFilter == f.id;
                          return GestureDetector(
                            onTap: () => setState(() => activeFilter = f.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active ? kPrimary : (isDark ? kDarkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: active ? const [BoxShadow(color: Colors.black12, blurRadius: 6)] : null,
                              ),
                              child: Text(f.label, style: TextStyle(color: active ? Colors.white : (isDark ? kDarkText : Colors.grey.shade700))),
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
                              Icon(LucideIcons.shopping_bag, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Aucun produit disponible', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: list.map((p) {
                          final dailyPrice = p['dailyPrice'] ?? 0;
                          final quantityAvailable = p['quantityAvailable'] ?? 0;
                          final quantityTotal = p['quantityTotal'] ?? 0;
                          final isAvailable = p['isAvailable'] ?? true;
                          final imageUrl = p['imageUrl'];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: EdgeInsets.zero,
                              clipBehavior: Clip.hardEdge,
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 112,
                                      height: 112,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
                                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                                        image: imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: imageUrl == null
                                          ? const Icon(LucideIcons.package, color: Colors.white, size: 40)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p['name'] ?? 'Sans nom', style: TextStyle(color: isDark ? kDarkText : kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          if (p['description'] != null)
                                            Text(p['description'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.package, size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(p['category']?['name'] ?? 'Catégorie', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.box, size: 14, color: kPrimary),
                                              const SizedBox(width: 6),
                                              Text('$quantityAvailable/$quantityTotal disponibles', style: const TextStyle(color: kPrimary)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('$dailyPrice MAD/jour', style: const TextStyle(color: kPrimary, fontSize: 18)),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isAvailable 
                                                      ? Colors.green.shade100.withOpacity(isDark ? 0.2 : 1.0)
                                                      : Colors.red.shade100.withOpacity(isDark ? 0.2 : 1.0),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  isAvailable 
                                                      ? appProvider.translate('Disponible', 'Available')
                                                      : appProvider.translate('Indisponible', 'Unavailable'),
                                                  style: TextStyle(
                                                    color: isAvailable 
                                                        ? (isDark ? Colors.green.shade400 : Colors.green.shade700)
                                                        : (isDark ? Colors.red.shade400 : Colors.red.shade700),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

class _Filter {
  final String id;
  final String label;
  _Filter(this.id, this.label);
}
