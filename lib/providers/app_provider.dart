import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/local_db_service.dart';
import '../services/google_sheets_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final LocalDbService _dbService = LocalDbService();
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  List<Customer> _customers = [];
  List<Product> _products = [];
  List<KhataTransaction> _transactions = [];

  String _languageCode = 'en';
  bool _notificationsEnabled = true;
  bool _modernView = true;
  bool _isOnline = false;
  bool _isSyncing = false;
  String _spreadsheetId = '';
  String _customerFilter = 'all'; // 'all', 'late', 'customer_owes', 'we_owe'
  String _searchQuery = '';

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters
  String get languageCode => _languageCode;
  bool get isUrdu => _languageCode == 'ur';
  bool get notificationsEnabled => _notificationsEnabled;
  bool get modernView => _modernView;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  bool get isSignedIn => _sheetsService.currentUser != null;
  String? get userEmail => _sheetsService.currentUser?.email;
  String get customerFilter => _customerFilter;

  List<Product> get products => _products;
  List<KhataTransaction> get transactions => _transactions;

  List<Customer> get filteredCustomers {
    return _customers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
      if (!matchesSearch) return false;

      final currentBalance = calculateCurrentCustomerBalance(c.id);
      if (_customerFilter == 'late') return c.isLatePayment;
      if (_customerFilter == 'customer_owes') return currentBalance > 0;
      if (_customerFilter == 'we_owe') return currentBalance < 0;
      return true;
    }).toList();
  }

  Future<void> initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('lang') ?? 'en';
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _modernView = prefs.getBool('modern_view') ?? true;
    _spreadsheetId = prefs.getString('spreadsheet_id') ?? '';

    loadLocalData();
    _initConnectivityListener();
    await NotificationService.checkAndNotifyLatePayments(_customers, _notificationsEnabled);
  }

  void loadLocalData() {
    _customers = _dbService.getAllCustomers();
    _products = _dbService.getAllProducts();
    _transactions = _dbService.getAllTransactions();
    notifyListeners();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      if (hasConnection && !_isOnline) {
        _isOnline = true;
        autoSyncIfPossible();
      } else {
        _isOnline = hasConnection;
      }
      notifyListeners();
    });
  }

  // Language & Settings
  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> toggleModernView(bool value) async {
    _modernView = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modern_view', value);
    notifyListeners();
  }

  Future<void> setSpreadsheetId(String id) async {
    _spreadsheetId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spreadsheet_id', id);
    notifyListeners();
  }

  // Filtering
  void setCustomerFilter(String filter) {
    _customerFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Google Auth
  Future<bool> signInWithGoogle() async {
    final success = await _sheetsService.signInWithGoogle();
    if (success) {
      await autoSyncIfPossible();
    }
    notifyListeners();
    return success;
  }

  Future<void> signOutGoogle() async {
    await _sheetsService.signOut();
    notifyListeners();
  }

  // Core Product Actions
  Future<void> addProduct(String name, double price, int stock) async {
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      stock: stock,
    );
    await _dbService.saveProduct(product);
    loadLocalData();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _dbService.saveProduct(updatedProduct);
    loadLocalData();
  }

  Future<void> deleteProduct(String productId) async {
    final box = Hive.box<Product>('products');
    await box.delete(productId);
    loadLocalData();
  }

  // Core Customer & Transaction Actions
  Future<void> deleteCustomer(String customerId) async {
    final customerBox = Hive.box<Customer>('customers');
    await customerBox.delete(customerId);

    // Also delete associated transactions
    final transactionBox = Hive.box<KhataTransaction>('transactions');
    final txsToDelete = transactionBox.values.where((tx) => tx.customerId == customerId).toList();
    for (var tx in txsToDelete) {
      await transactionBox.delete(tx.id);
    }

    loadLocalData();
  }

  double calculateCurrentCustomerBalance(String customerId) {
    final customerTxs = _transactions.where((tx) => tx.customerId == customerId);
    double balance = 0.0;
    for (var tx in customerTxs) {
      if (tx.type == 'customer_owes' || tx.type == 'payment_sent') {
        balance += tx.amount;
      } else if (tx.type == 'payment_received' || tx.type == 'we_owe') {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  Future<void> recalculateCustomerBalance(String customerId) async {
    final customerIndex = _customers.indexWhere((c) => c.id == customerId);
    if (customerIndex != -1) {
      _customers[customerIndex].balance = calculateCurrentCustomerBalance(customerId);
      await _dbService.saveCustomer(_customers[customerIndex]);
      loadLocalData();
    }
  }

  Future<void> addCustomerWithTransaction({
    required String name,
    required String phone,
    required String note,
    required List<String> selectedProducts,
    required double amount,
    required bool customerHasToPay,
  }) async {
    final now = DateTime.now();
    final customerId = now.millisecondsSinceEpoch.toString();
    final adjustedBalance = customerHasToPay ? amount : -amount;

    final customer = Customer(
      id: customerId,
      name: name,
      phone: phone,
      note: note,
      purchasedProducts: selectedProducts,
      balance: adjustedBalance,
      lastTransactionDate: now,
    );

    final transaction = KhataTransaction(
      id: '${customerId}_tx',
      customerId: customerId,
      amount: amount,
      type: customerHasToPay ? 'customer_owes' : 'we_owe',
      date: now,
      products: selectedProducts,
    );

    await _dbService.saveCustomer(customer);
    await _dbService.saveTransaction(transaction);
    loadLocalData();
    await autoSyncIfPossible();
  }

  Future<void> addTransactionToCustomer({
    required String customerId,
    required double amount,
    required String type,
    required List<String> products,
    required String note,
  }) async {
    final now = DateTime.now();
    final newTx = KhataTransaction(
      id: now.millisecondsSinceEpoch.toString(),
      customerId: customerId,
      amount: amount,
      type: type,
      date: now,
      products: products,
      isSynced: false,
      note: note.isEmpty ? null : note,
    );

    await _dbService.saveTransaction(newTx);
    await recalculateCustomerBalance(customerId);
    loadLocalData();
    await autoSyncIfPossible();
  }

  Future<void> recordPayment(Customer customer, double amount, bool customerPaidUs) async {
    final now = DateTime.now();
    final transaction = KhataTransaction(
      id: '${now.millisecondsSinceEpoch}_pay',
      customerId: customer.id,
      amount: amount,
      type: customerPaidUs ? 'payment_received' : 'payment_sent',
      date: now,
      products: [],
    );
    await _dbService.saveTransaction(transaction);
    await recalculateCustomerBalance(customer.id);

    loadLocalData();
    await autoSyncIfPossible();
  }

  Future<void> autoSyncIfPossible() async {
    if (!_isOnline || !isSignedIn || _spreadsheetId.isEmpty || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    await _sheetsService.syncDataToCloud(
      customers: _customers,
      transactions: _transactions,
      spreadsheetId: _spreadsheetId,
    );

    _isSyncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}