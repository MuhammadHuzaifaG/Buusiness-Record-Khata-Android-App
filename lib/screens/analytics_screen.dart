import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedFilter = 'all'; // 'all', 'customer_owes', 'payment_received', 'we_owe'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final customers = provider.filteredCustomers;
    final transactions = provider.transactions;

    double totalYouWillGet = 0;

    // Accurately aggregate all payment transactions into Payment Received KPI
    double totalPaymentReceived = transactions
        .where((tx) => tx.type == 'payment_received' || tx.type == 'payment_sent')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    for (var c in customers) {
      final balance = provider.calculateCurrentCustomerBalance(c.id);
      if (balance > 0) {
        totalYouWillGet += balance;
      }
    }

    int totalCustomersCount = customers.length;
    int totalTransactionsCount = transactions.length;

    // Filter transactions according to selected category
    final displayedTransactions = transactions.where((tx) {
      if (_selectedFilter == 'customer_owes') return tx.type == 'customer_owes';
      if (_selectedFilter == 'payment_received') return tx.type == 'payment_received' || tx.type == 'payment_sent';
      if (_selectedFilter == 'we_owe') return tx.type == 'we_owe';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.isUrdu ? 'تجزیات اور رپورٹس' : 'Analytics & Financial Reports',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 4 KPI Cards Layout (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: 'Payment Received',
                    amount: 'PKR ${totalPaymentReceived.toStringAsFixed(0)}',
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                    icon: Icons.download_done_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpiCard(
                    title: 'You Will Get',
                    amount: 'PKR ${totalYouWillGet.toStringAsFixed(0)}',
                    color: AppTheme.alertRed,
                    bgColor: Colors.red.shade50,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: "Total Customers",
                    amount: '$totalCustomersCount',
                    color: AppTheme.primaryColor,
                    bgColor: Colors.blue.shade50,
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpiCard(
                    title: "Total Transactions",
                    amount: '$totalTransactionsCount',
                    color: Colors.deepOrange,
                    bgColor: Colors.deepOrange.shade50,
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaction Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: [
                      _selectedFilter == 'all',
                      _selectedFilter == 'customer_owes',
                      _selectedFilter == 'payment_received',
                      _selectedFilter == 'we_owe',
                    ],
                    onPressed: (index) {
                      setState(() {
                        if (index == 0) _selectedFilter = 'all';
                        if (index == 1) _selectedFilter = 'customer_owes';
                        if (index == 2) _selectedFilter = 'payment_received';
                        if (index == 3) _selectedFilter = 'we_owe';
                      });
                    },
                    constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
                    children: const [
                      Text('All', style: TextStyle(fontSize: 10)),
                      Text('C. Owes', style: TextStyle(fontSize: 10)),
                      Text('Received', style: TextStyle(fontSize: 10)),
                      Text('We Pay', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color-coded Transaction Records List
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: displayedTransactions.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No transactions match this filter', style: TextStyle(color: Colors.grey))),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedTransactions.length > 15 ? 15 : displayedTransactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final tx = displayedTransactions[index];
                  final bool isPositive = tx.type == 'customer_owes' || tx.type == 'payment_sent';

                  final Color themeColor = isPositive ? AppTheme.alertRed : Colors.green.shade700;
                  final Color backgroundBadge = isPositive ? Colors.red.shade50 : Colors.green.shade50;

                  String label = 'Transaction';
                  if (tx.type == 'customer_owes') label = 'Customer Owes';
                  if (tx.type == 'payment_received') label = 'Payment Received';
                  if (tx.type == 'we_owe') label = 'We Have to Pay';
                  if (tx.type == 'payment_sent') label = 'Payment Sent';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: backgroundBadge,
                      child: Icon(
                        isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      label,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: themeColor),
                    ),
                    subtitle: Text(
                      'Date: ${tx.date.toString().substring(0, 10)}${tx.products.isNotEmpty ? " • ${tx.products.join(', ')}" : ""}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      'PKR ${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: themeColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard({required String title, required String amount, required Color color, required Color bgColor, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}