import 'package:flutter/material.dart';
import '../main.dart';

class AppInput extends StatelessWidget {
  final String placeholder;
  final Widget? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const AppInput({
    super.key,
    required this.placeholder,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IconTheme(
                    data: IconThemeData(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    child: icon!,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
