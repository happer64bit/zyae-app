import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: BorderRadius.circular(12),
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
                            width: 100,
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
                      style: AppTheme.titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat("#,##0").format(product.price)} MMK',
                      style: AppTheme.priceStyle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppTheme.gapSmall),
                    Wrap(
                      spacing: AppTheme.gapSmall,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Qty: ${product.quantity.toStringAsFixed(0)} ${product.unit}',
                          style: AppTheme.captionStyle,
                        ),
                        if (product.isLowStock)
                          _buildStatusTag(
                            'Low stock',
                            AppTheme.stockWarningText,
                            AppTheme.stockWarningBg,
                            LucideIcons.triangleAlert,
                          )
                        else if (product.isOutOfStock)
                          _buildStatusTag(
                            'Out of stock',
                            AppTheme.stockErrorText,
                            AppTheme.stockErrorBg,
                            LucideIcons.circleAlert,
                          )
                        else if (product.isInStock)
                           _buildStatusTag(
                            'In stock',
                            AppTheme.stockSuccessText,
                            AppTheme.stockSuccessBg,
                            LucideIcons.circleCheck,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: Colors.grey),
            ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color textColor, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.captionStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
