import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';

class TopSellingCard extends StatelessWidget {
  final Product product;
  final int soldCount;
  final String soldLabel;

  const TopSellingCard({
    super.key,
    required this.product,
    required this.soldCount,
    required this.soldLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                image: product.imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(product.imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imagePath == null
                  ? const Center(
                      child: Icon(
                        LucideIcons.image,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
          ),
          Text(
            '$soldCount $soldLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
