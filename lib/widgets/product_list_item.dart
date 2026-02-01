import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                  image: product.imagePath != null
                      ? DecorationImage(
                          image: ResizeImage(
                            FileImage(File(product.imagePath!)),
                            width: 100, // Optimize memory usage
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imagePath == null
                    ? const Icon(LucideIcons.package, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Qty: ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (product.isLowStock)
                          _buildStatusTag(
                            'Low stock',
                            AppTheme.warningColor,
                            AppTheme.warningColor.withValues(alpha: 0.1),
                            LucideIcons.triangleAlert,
                          )
                        else if (product.isOutOfStock)
                          _buildStatusTag(
                            'Out of stock',
                            AppTheme.errorColor,
                            AppTheme.errorColor.withValues(alpha: 0.1),
                            LucideIcons.circleAlert,
                          )
                        else if (product.isInStock)
                           _buildStatusTag(
                            'In stock',
                            AppTheme.successColor,
                            AppTheme.successColor.withValues(alpha: 0.1),
                            LucideIcons.circleCheck,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(0)} MMK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: Colors.grey),
            ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
