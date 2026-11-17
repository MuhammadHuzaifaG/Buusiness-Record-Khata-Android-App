import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final transactions = provider.transactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: transactions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 72, color: Colors.blue.shade200),
            const SizedBox(height: 16),
            Text(
              provider.isUrdu ? 'کوئی لاگ موجود نہیں ہے' : 'No activity logs found.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(tx.date);
          final bool isOwes = tx.type == 'customer_owes';
          final bool isPayment = tx.type == 'payment_received';

          Color badgeColor = AppTheme.primaryColor;
          String typeLabel = tx.type;

          if (isOwes) {
            badgeColor = AppTheme.alertRed;
            typeLabel = 'Customer Owes';
          } else if (isPayment) {
            badgeColor = Colors.green.shade700;
            typeLabel = 'Payment Received';
          } else {
            badgeColor = Colors.amber.shade800;
            typeLabel = 'We Have to Pay';
          }

          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: badgeColor.withOpacity(0.1),
                child: Icon(Icons.receipt_long_rounded, color: badgeColor),
              ),
              title: Text(
                typeLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: badgeColor),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Date: $formattedDate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (tx.products.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Items: ${tx.products.join(", ")}', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                  ],
                  if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Note: ${tx.note}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                  ],
                ],
              ),
              trailing: Text(
                'PKR ${tx.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: badgeColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}