import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/localization.dart';
import '../core/theme.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

  List<String> _selectedProducts = [];
  String _transactionType = 'customer_owes'; // 'customer_owes', 'payment_received', 'we_owe'

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final products = provider.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText(provider.languageCode, 'add_customer')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: provider.isUrdu ? 'گاہک کا نام' : 'Customer Name *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: provider.isUrdu ? 'فون نمبر' : 'Phone Number *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: provider.isUrdu ? 'نوٹ (اختیاری)' : 'Note / Remarks',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: provider.isUrdu ? 'مصنوعات منتخب کریں' : 'Select Product (Items)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                  items: products.map((p) {
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
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (PKR) *',
                    border: OutlineInputBorder(),
                    prefixText: 'PKR ',
                    prefixIcon: Icon(Icons.money),
                  ),
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Enter valid amount' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final amount = double.parse(_amountController.text);
                      // Determine balance impact based on selected combo type
                      bool customerHasToPay = _transactionType == 'customer_owes';

                      await provider.addCustomerWithTransaction(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        note: _noteController.text,
                        selectedProducts: _selectedProducts,
                        amount: amount,
                        customerHasToPay: customerHasToPay,
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Customer & Record',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}