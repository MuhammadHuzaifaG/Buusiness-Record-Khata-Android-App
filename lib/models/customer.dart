import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String note;

  @HiveField(4)
  List<String> purchasedProducts;

  @HiveField(5)
  double balance; // Positive = Customer has to pay, Negative = We have to pay

  @HiveField(6)
  DateTime lastTransactionDate;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.note,
    required this.purchasedProducts,
    required this.balance,
    required this.lastTransactionDate,
  });

  bool get isLatePayment =>
      balance > 0 && DateTime.now().difference(lastTransactionDate).inDays > 7;
}