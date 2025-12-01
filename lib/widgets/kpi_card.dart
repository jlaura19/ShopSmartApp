import 'package:flutter/material.dart';
import 'package:smartshop_app/services/analytics_service.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
    final profitMargin = kpiData.totalRevenue > 0 ? ((kpiData.profit / kpiData.totalRevenue) * 100).toStringAsFixed(1) : '0.0';

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        KPICard(
          title: 'Total Revenue',
          value: '\$${kpiData.totalRevenue.toStringAsFixed(2)}',
          subtitle: 'Earnings',
          icon: Icons.trending_up,
          color: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
        KPICard(
          title: 'Total Expenses',
          value: '\$${kpiData.totalExpenses.toStringAsFixed(2)}',
          subtitle: 'Costs',
          icon: Icons.money_off,
          color: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
        ),
        KPICard(
          title: 'Net Profit',
          value: '\$${kpiData.profit.toStringAsFixed(2)}',
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
          value: '\$${(kpiData.totalSales > 0 ? kpiData.totalRevenue / kpiData.totalSales : 0).toStringAsFixed(2)}',
          subtitle: 'Per Transaction',
          icon: Icons.calculate,
          color: Colors.teal,
          backgroundColor: Colors.teal.withOpacity(0.1),
        ),
      ],
    );
  }
}
