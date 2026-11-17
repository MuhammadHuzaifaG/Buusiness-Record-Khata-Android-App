import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class LocalDbService {
  static const String customerBoxName = 'customers';
  static const String productBoxName = 'products';
  static const String transactionBoxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CustomerAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProductAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(KhataTransactionAdapter());

    await Hive.openBox<Customer>(customerBoxName);
    await Hive.openBox<Product>(productBoxName);
    await Hive.openBox<KhataTransaction>(transactionBoxName);
  }

  Box<Customer> get customersBox => Hive.box<Customer>(customerBoxName);
  Box<Product> get productsBox => Hive.box<Product>(productBoxName);
  Box<KhataTransaction> get transactionsBox => Hive.box<KhataTransaction>(transactionBoxName);

  Future<void> saveCustomer(Customer customer) async {
    await customersBox.put(customer.id, customer);
  }

  Future<void> saveProduct(Product product) async {
    await productsBox.put(product.id, product);
  }

  Future<void> saveTransaction(KhataTransaction transaction) async {
    await transactionsBox.put(transaction.id, transaction);
  }

  List<Customer> getAllCustomers() => customersBox.values.toList();
  List<Product> getAllProducts() => productsBox.values.toList();
  List<KhataTransaction> getAllTransactions() => transactionsBox.values.toList();
}