import 'package:flutter/material.dart';

class ToggleButtonWidget extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const ToggleButtonWidget({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5A8DEE) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}