import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imagePath != null) ...[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(product.imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                product.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.imagePath == null) const Spacer(),
              const SizedBox(height: 4),
              Text(
                '${product.price.toStringAsFixed(0)} MMK',
                style: const TextStyle(
                  color: AppTheme.moneyColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.quantity.toStringAsFixed(0)} ${product.unit} left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
