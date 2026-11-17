import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String? customerPhone;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _generatePdfInvoice(List<KhataTransaction> transactions, double netBalance) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('DIGITAL KHATA - CUSTOMER INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Customer: ${widget.customerName}'),
              if (widget.customerPhone != null) pw.Text('Phone: ${widget.customerPhone}'),
              pw.Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}'),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Net Balance: PKR ${netBalance.abs().toStringAsFixed(2)} (${netBalance >= 0 ? "You will get" : "You will give"})',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Type', 'Products / Items', 'Amount (PKR)'],
                data: transactions.map((tx) {
                  return [
                    DateFormat('dd MMM yyyy').format(tx.date),
                    tx.type == 'customer_owes' ? 'Given (Owes)' : 'Payment Received',
                    tx.products.isNotEmpty ? tx.products.join(', ') : (tx.note ?? '-'),
                    tx.amount.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _captureAndShareScreenshot() async {
    try {
      final imageFile = await _screenshotController.capture(delay: const Duration(milliseconds: 150));
      if (imageFile != null) {
        final xFile = XFile.fromData(
          imageFile,
          mimeType: 'image/png',
          name: 'invoice_${widget.customerName}.png',
        );
        await Share.shareXFiles([xFile], text: 'Invoice statement for ${widget.customerName}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture screenshot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customerName, style: const TextStyle(fontSize: 18)),
            if (widget.customerPhone != null && widget.customerPhone!.isNotEmpty)
              Text(
                widget.customerPhone!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          // Visible PDF Invoice Button
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF Invoice',
            onPressed: () {
              final box = Hive.box<KhataTransaction>('transactions');
              final transactions = box.values.where((tx) => tx.customerId == widget.customerId).toList();
              double totalOwes = transactions.where((t) => t.type == 'customer_owes').fold(0.0, (s, t) => s + t.amount);
              double totalOwe = transactions.where((t) => t.type != 'customer_owes').fold(0.0, (s, t) => s + t.amount);
              _generatePdfInvoice(transactions, totalOwes - totalOwe);
            },
          ),
          // Visible Screenshot / Image Share Button
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Screenshot & Share',
            onPressed: _captureAndShareScreenshot,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ValueListenableBuilder<Box<KhataTransaction>>(
            valueListenable: Hive.box<KhataTransaction>('transactions').listenable(),
            builder: (context, box, _) {
              final transactions = box.values
                  .where((tx) => tx.customerId == widget.customerId)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              double totalCustomerOwes = 0.0;
              double totalWeOwe = 0.0;

              for (var tx in transactions) {
                if (tx.type == 'customer_owes') {
                  totalCustomerOwes += tx.amount;
                } else {
                  totalWeOwe += tx.amount;
                }
              }

              final double netBalance = totalCustomerOwes - totalWeOwe;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: netBalance >= 0 ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: netBalance >= 0 ? Colors.red.shade200 : Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          netBalance >= 0 ? 'Customer Owes You' : 'You Owe Customer',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PKR ${netBalance.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: netBalance >= 0 ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(
                      child: Text(
                        'No transactions yet. Tap + to add one.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final bool isCustomerOwes = tx.type == 'customer_owes';
                        final String formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(tx.date);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isCustomerOwes ? Colors.red.shade100 : Colors.green.shade100,
                            child: Icon(
                              isCustomerOwes ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isCustomerOwes ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                          title: Text(
                            isCustomerOwes ? 'You Gave (Customer Owes)' : 'You Got (Payment)',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              if (tx.products.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Items: ${tx.products.join(", ")}',
                                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                                ),
                              ],
                              if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Note: ${tx.note}',
                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                          trailing: Text(
                            'PKR ${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCustomerOwes ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(customerId: widget.customerId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}