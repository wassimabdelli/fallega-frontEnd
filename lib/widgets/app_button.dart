import 'package:flutter/material.dart';
import '../main.dart';

enum ButtonVariant { primary, secondary, outline, ghost }
enum ButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AppButton({
    super.key,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.fullWidth = false,
    this.onPressed,
    required this.child,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    final sizePadding = switch (size) {
      ButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    };
    final bg = switch (variant) {
      ButtonVariant.primary => kPrimary,
      ButtonVariant.secondary => kDark,
      ButtonVariant.outline => Colors.transparent,
      ButtonVariant.ghost => Colors.transparent,
    };
    final fg = switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary => Colors.white,
      ButtonVariant.outline => kPrimary,
      ButtonVariant.ghost => kDark,
    };
    final border = switch (variant) {
      ButtonVariant.outline => BorderSide(color: kPrimary, width: 2),
      _ => BorderSide(color: Colors.transparent),
    };
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: border);
    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(bg),
      foregroundColor: WidgetStatePropertyAll(fg),
      shape: WidgetStatePropertyAll(shape),
      minimumSize: WidgetStatePropertyAll(Size(fullWidth ? double.infinity : 0, 0)),
      padding: WidgetStatePropertyAll(padding ?? sizePadding),
      elevation: WidgetStatePropertyAll(variant == ButtonVariant.primary || variant == ButtonVariant.secondary ? 2 : 0),
      overlayColor: WidgetStatePropertyAll((variant == ButtonVariant.outline || variant == ButtonVariant.ghost) ? kLight : kPrimaryDark.withOpacity(0.1)),
    );
    return TextButton(onPressed: onPressed, style: style, child: child);
  }
}
