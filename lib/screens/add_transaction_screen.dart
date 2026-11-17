import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String customerId;

  const AddTransactionScreen({super.key, required this.customerId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  List<String> _selectedProducts = [];
  String _transactionType = 'customer_owes'; // 'customer_owes', 'payment_received', 'we_owe'
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.parse(_amountController.text.trim());
    final String note = _noteController.text.trim();

    final newTx = KhataTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: widget.customerId,
      amount: amount,
      type: _transactionType,
      date: _selectedDate,
      products: _selectedProducts,
      isSynced: false,
      note: note.isEmpty ? null : note,
    );

    final box = Hive.box<KhataTransaction>('transactions');
    await box.put(newTx.id, newTx);

    // Update customer current cumulative balance
    final customerProvider = Provider.of<AppProvider>(context, listen: false);
    await customerProvider.recalculateCustomerBalance(widget.customerId);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final availableProducts = provider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry / Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Combo Box Option for Transaction Type
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer_owes', child: Text('Customer Owes')),
                  DropdownMenuItem(value: 'payment_received', child: Text('Payment Received')),
                  DropdownMenuItem(value: 'we_owe', child: Text('We Have to Pay to Someone')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _transactionType = val);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Pre-Added Product (Items)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                items: availableProducts.map((p) {
                  return DropdownMenuItem<String>(
                    value: p.name,
                    child: Text('${p.name} (PKR ${p.price})'),
                  );
                }).toList(),
                onChanged: (productName) {
                  if (productName != null && !_selectedProducts.contains(productName)) {
                    setState(() {
                      _selectedProducts.add(productName);
                    });
                  }
                },
                value: null,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _selectedProducts.map((prod) {
                  return Chip(
                    label: Text(prod),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedProducts.remove(prod);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'PKR ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
                trailing: const Text('Change', style: TextStyle(color: Colors.blue)),
                onTap: _pickDate,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}