import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white, // Actually the first one is green tinted in the image?
          // Looking at image: "Today's Sales" has green tint BG? No, looks like white card with green icon circle.
          // Wait, "Today's Sales" card has a very light green background?
          // Let's look closely. "Today's Overview" -> "Today's Sales" card background is LIGHT GREEN.
          // "Transactions" card background is WHITE.
          // I'll add a backgroundColor property.
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
