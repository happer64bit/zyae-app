import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/screens/sale_detail_screen.dart';
import 'package:zyae/theme/app_theme.dart';

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleDetailScreen(sale: sale),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long,
                  color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productNames,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${sale.totalItems} items',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
