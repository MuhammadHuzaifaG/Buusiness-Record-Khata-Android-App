import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/localization.dart';
import '../core/theme.dart';
import '../models/product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _showDeleteProductDialog(BuildContext context, AppProvider provider, String productId, String productName) {
    bool acknowledge = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Delete $productName?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will permanently remove the product from your inventory.'),
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
                await provider.deleteProduct(productId);
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
    final products = provider.products;

    return Scaffold(
      body: products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              provider.isUrdu ? 'کوئی پروڈکٹ موجود نہیں ہے' : 'No products added yet.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                child: const Icon(Icons.shopping_bag, color: AppTheme.secondaryColor),
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('Stock: ${product.stock} units'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PKR ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                    onPressed: () => _showProductDialog(context, provider, existingProduct: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.alertRed, size: 20),
                    onPressed: () => _showDeleteProductDialog(context, provider, product.id, product.name),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context, provider),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.getText(provider.languageCode, 'add_product'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, AppProvider provider, {Product? existingProduct}) {
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final priceController = TextEditingController(text: existingProduct?.price != null ? existingProduct!.price.toString() : '');
    final stockController = TextEditingController(text: existingProduct?.stock != null ? existingProduct!.stock.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingProduct == null ? 'Add New Product' : 'Edit Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (PKR)', border: OutlineInputBorder()),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity', border: OutlineInputBorder()),
                validator: (val) => val == null || int.tryParse(val) == null ? 'Enter valid stock' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = nameController.text;
                final price = double.parse(priceController.text);
                final stock = int.parse(stockController.text);

                if (existingProduct == null) {
                  await provider.addProduct(name, price, stock);
                } else {
                  await provider.updateProduct(
                    existingProduct.copyWith(name: name, price: price, stock: stock),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}