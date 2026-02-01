import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/screens/sale_detail_screen.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class SaleListItem extends StatelessWidget {
  final Sale sale;

  const SaleListItem({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final productNames = sale.items.map((i) => i.product.name).join(', ');
    final numberFormat = NumberFormat("#,##0");
    
    final now = DateTime.now();
    final isToday = sale.date.year == now.year && sale.date.month == now.month && sale.date.day == now.day;
    final dateText = isToday
        ? DateFormat('hh:mm a').format(sale.date)
        : DateFormat('MMM dd, hh:mm a').format(sale.date);

    return TouchableOpacity(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleDetailScreen(sale: sale),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.receipt,
                color: AppTheme.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productNames,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${sale.totalItems} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${numberFormat.format(sale.total)} MMK',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
