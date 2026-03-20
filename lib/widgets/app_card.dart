import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hoverable;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.hoverable = false,
    this.onTap,
    this.clipBehavior = Clip.none,
  });
  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: card);
    }
    return card;
  }
}
