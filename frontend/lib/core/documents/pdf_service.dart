import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../features/sales/models/sales_models.dart';
import '../../features/purchases/models/purchases_models.dart';
import '../../features/payments/models/payments_models.dart';
import '../../features/expenses/models/expenses_models.dart';

class PdfService {
  static const String _businessName = 'AHSAN TYRE';

  static pw.ThemeData _buildTheme() {
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  // --- 1. Sales Invoice ---

  static Future<Uint8List> generateSalesInvoice(
      Sale sale, List<SaleItem> items) async {
    final pdf = pw.Document(theme: _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('SALES INVOICE'),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Customer: ${sale.customerName ?? "Walk-in Customer"}',
                        style:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      if (sale.vehicleNumber != null)
                        pw.Text('Vehicle: ${sale.vehicleNumber}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // FIX BUG-001: Sale model field is invoiceNumber, not saleNumber
                      pw.Text(
                        'Invoice No: ${sale.invoiceNumber}',
                        style:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(sale.saleDate.toLocal())}',
                      ),
                      pw.Text(
                        'Status: ${sale.paymentStatus}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: _getStatusColor(sale.paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                headerHeight: 25,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headers: ['Item', 'Qty', 'Unit Price (Rs)', 'Total (Rs)'],
                // FIX BUG-002: SaleItem has no .product object; use productName/productSize directly
                data: items
                    .map(
                      (item) => [
                        '${item.productName}\n${item.productSize}',
                        item.quantity.toInt().toString(),
                        NumberFormat('#,##0').format(item.unitPrice),
                        NumberFormat('#,##0').format(item.lineTotal),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Total Amount', sale.totalAmount),
                        _buildTotalRow('Paid Amount', sale.paidAmount),
                        pw.Divider(color: PdfColors.grey400),
                        _buildTotalRow(
                          'Outstanding',
                          sale.dueAmount,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- 2. Purchase Bill ---

  static Future<Uint8List> generatePurchaseBill(
      Purchase purchase, List<PurchaseItem> items) async {
    final pdf = pw.Document(theme: _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('PURCHASE BILL'),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Supplier: ${purchase.supplierName}',
                        style:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Purchase Ref: ${purchase.purchaseNumber}',
                        style:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(purchase.purchaseDate.toLocal())}',
                      ),
                      pw.Text(
                        'Status: ${purchase.paymentStatus}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: _getStatusColor(purchase.paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                headerHeight: 25,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headers: ['Item', 'Qty', 'Unit Cost (Rs)', 'Total (Rs)'],
                // FIX BUG-003: PurchaseItem has no .product object; use productName/productSize directly
                data: items
                    .map(
                      (item) => [
                        '${item.productName}\n${item.productSize}',
                        item.quantity.toInt().toString(),
                        NumberFormat('#,##0').format(item.unitCost),
                        NumberFormat('#,##0').format(item.lineTotal),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Total Amount', purchase.totalAmount),
                        _buildTotalRow('Paid Amount', purchase.paidAmount),
                        pw.Divider(color: PdfColors.grey400),
                        _buildTotalRow(
                          'Outstanding',
                          purchase.dueAmount,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- 3. Payment Receipt ---

  static Future<Uint8List> generatePaymentReceipt(Payment payment) async {
    final pdf = pw.Document(theme: _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final isReceived = payment.direction == 'IN';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                isReceived
                    ? 'CUSTOMER PAYMENT RECEIPT'
                    : 'SUPPLIER PAYMENT RECEIPT',
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Receipt No', payment.paymentNumber),
                    _buildDetailRow(
                      'Date',
                      DateFormat('dd MMMM yyyy')
                          .format(payment.paymentDate.toLocal()),
                    ),
                    _buildDetailRow(
                      isReceived ? 'Received From' : 'Paid To',
                      payment.partyName,
                    ),
                    _buildDetailRow(
                      'Amount',
                      'Rs. ${NumberFormat('#,##0').format(payment.amount)}',
                      isBold: true,
                    ),
                    _buildDetailRow(
                      'Payment Method',
                      payment.paymentMethodName,
                    ),
                    if (payment.reference != null &&
                        payment.reference!.isNotEmpty)
                      _buildDetailRow('Reference', payment.reference!),
                    if (payment.notes != null && payment.notes!.isNotEmpty)
                      _buildDetailRow('Notes', payment.notes!),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- 4. Expense Record ---

  static Future<Uint8List> generateExpenseRecord(Expense expense) async {
    final pdf = pw.Document(theme: _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('EXPENSE RECORD'),
              pw.SizedBox(height: 30),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Expense No', expense.expenseNumber),
                    _buildDetailRow(
                      'Date',
                      DateFormat('dd MMMM yyyy')
                          .format(expense.expenseDate.toLocal()),
                    ),
                    _buildDetailRow('Category', expense.categoryName),
                    _buildDetailRow(
                      'Amount',
                      'Rs. ${NumberFormat('#,##0').format(expense.amount)}',
                      isBold: true,
                    ),
                    _buildDetailRow(
                      'Payment Method',
                      expense.paymentMethodName,
                    ),
                    if (expense.reference != null &&
                        expense.reference!.isNotEmpty)
                      _buildDetailRow('Reference', expense.reference!),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      _buildDetailRow(
                        'Notes/Description',
                        expense.description!,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- Helpers ---

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _businessName,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 16,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(color: PdfColors.black),
      ],
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight:
                  isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            'Rs. ${NumberFormat('#,##0').format(amount)}',
            style: pw.TextStyle(
              fontWeight:
                  isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight:
                    isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return PdfColors.green700;
      case 'Credit':
        return PdfColors.red700;
      default:
        return PdfColors.orange700;
    }
  }
}
