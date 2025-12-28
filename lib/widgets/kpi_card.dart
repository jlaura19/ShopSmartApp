import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop_app/services/analytics_service.dart';
import 'package:smartshop_app/providers/currency_provider.dart';

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const KPICard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.5),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class KPIGridView extends StatelessWidget {
  final KPIData kpiData;

  const KPIGridView({
    Key? key,
    required this.kpiData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profitMargin = kpiData.totalRevenue > 0 
        ? ((kpiData.profit / kpiData.totalRevenue) * 100).toStringAsFixed(1) 
        : '0.0';

    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, _) {
        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            KPICard(
              title: 'Total Revenue',
              value: currencyProvider.format(kpiData.totalRevenue),
              subtitle: 'Earnings',
              icon: Icons.trending_up,
              color: Colors.green,
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
            KPICard(
              title: 'Total Expenses',
              value: currencyProvider.format(kpiData.totalExpenses),
              subtitle: 'Costs',
              icon: Icons.money_off,
              color: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            KPICard(
              title: 'Net Profit',
              value: currencyProvider.format(kpiData.profit),
              subtitle: 'Net Income',
              icon: Icons.attach_money,
              color: Colors.blue,
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            KPICard(
              title: 'Total Sales',
              value: '${kpiData.totalSales}',
              subtitle: 'Transactions',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              backgroundColor: Colors.orange.withOpacity(0.1),
            ),
            KPICard(
              title: 'Profit Margin',
              value: '$profitMargin%',
              subtitle: 'Efficiency',
              icon: Icons.percent,
              color: Colors.purple,
              backgroundColor: Colors.purple.withOpacity(0.1),
            ),
            KPICard(
              title: 'Avg Sale Value',
              value: currencyProvider.format(
                kpiData.totalSales > 0 
                    ? kpiData.totalRevenue / kpiData.totalSales 
                    : 0
              ),
              subtitle: 'Per Transaction',
              icon: Icons.calculate,
              color: Colors.teal,
              backgroundColor: Colors.teal.withOpacity(0.1),
            ),
          ],
        );
      },
    );
  }
}
