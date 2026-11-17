import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class KhataTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String type; // 'customer_owes' or 'we_owe'

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  List<String> products;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String? note; // Added note field for transaction details

  KhataTransaction({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.date,
    required this.products,
    this.isSynced = false,
    this.note,
  });
}