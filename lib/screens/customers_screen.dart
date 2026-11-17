import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import 'customer_detail_screen.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // Sort criteria: 'activity' (default), 'amount_desc', 'amount_asc', 'name'
  String _sortCriteria = 'activity';

  void _showDeleteCustomerDialog(BuildContext context, AppProvider provider, String customerId, String customerName) {
    bool acknowledge = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Delete $customerName?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will permanently remove the customer and their financial records.'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('I acknowledge that this action cannot be undone.', style: TextStyle(fontSize: 13)),
                value: acknowledge,
                onChanged: (val) {
                  setStateDialog(() {
                    acknowledge = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: acknowledge
                  ? () async {
                await provider.deleteCustomer(customerId);
                Navigator.pop(ctx);
              }
                  : null,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final customers = List.of(provider.filteredCustomers);

    // Apply sorting based on user selection
    customers.sort((a, b) {
      if (_sortCriteria == 'amount_desc') {
        final balA = provider.calculateCurrentCustomerBalance(a.id).abs();
        final balB = provider.calculateCurrentCustomerBalance(b.id).abs();
        return balB.compareTo(balA);
      } else if (_sortCriteria == 'amount_asc') {
        final balA = provider.calculateCurrentCustomerBalance(a.id).abs();
        final balB = provider.calculateCurrentCustomerBalance(b.id).abs();
        return balA.compareTo(balB);
      } else if (_sortCriteria == 'name') {
        return a.name.compareTo(b.name);
      } else {
        // Default: Sort by recent activity date (newest first)
        final dateA = a.lastTransactionDate ?? DateTime(2000);
        final dateB = b.lastTransactionDate ?? DateTime(2000);
        return dateB.compareTo(dateA);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // Search Bar & Sort Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: provider.isUrdu ? 'گاہک تلاش کریں...' : 'Search by name or phone...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E88E5)),
                      filled: true,
                      fillColor: const Color(0xFFF0F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort_rounded, color: Color(0xFF1E88E5)),
                  tooltip: 'Sort Customers',
                  onSelected: (val) {
                    setState(() {
                      _sortCriteria = val;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'activity', child: Text('Sort by: Recent Activity')),
                    const PopupMenuItem(value: 'amount_desc', child: Text('Sort by: Highest Amount')),
                    const PopupMenuItem(value: 'amount_asc', child: Text('Sort by: Lowest Amount')),
                    const PopupMenuItem(value: 'name', child: Text('Sort by: Name (A-Z)')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: customers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 72, color: Colors.blue.shade200),
                  const SizedBox(height: 16),
                  Text(
                    provider.isUrdu ? 'کوئی گاہک موجود نہیں ہے' : 'No customers found.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                final currentBalance = provider.calculateCurrentCustomerBalance(customer.id);
                final isReceiving = currentBalance >= 0;

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailScreen(
                            customerId: customer.id,
                            customerName: customer.name,
                            customerPhone: customer.phone,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isReceiving ? Colors.red.shade50 : Colors.green.shade50,
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: isReceiving ? AppTheme.alertRed : Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                if (customer.phone.isNotEmpty)
                                  Text(customer.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PKR ${currentBalance.abs().toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isReceiving ? AppTheme.alertRed : Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isReceiving ? Colors.red.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isReceiving ? 'You will get' : 'Payment Received',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isReceiving ? Colors.red.shade700 : Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20),
                            onPressed: () => _showDeleteCustomerDialog(context, provider, customer.id, customer.name),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          provider.isUrdu ? 'نیا گاہک' : 'Add Customer',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}