import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCurrency(double amount, {String currencySymbol = 'USD'}) {
    return NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  pw.Widget _buildWatermark(pw.MemoryImage logoImage) {
    return pw.Opacity(
      opacity: 0.05,
      child: pw.Center(
        child: pw.Image(
          logoImage,
          fit: pw.BoxFit.contain,
          height: 300,
          width: 300,
        ),
      ),
    );
  }

  Future<File> generatePdf({
    required String companyName,
    required String invoiceNumber,
    required String reference,
    required DateTime date,
    required DateTime dueDate,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> paidItems,
    required String accountName,
    required String bankName,
    required String accountNumber,
    required double amount,
    required double paidAmount,
    required Uint8List? signature,
    required String authorizedName,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();

    try {
      // Load logo image
      final logoData = await rootBundle.load('assets/images/logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Create a page theme with a background watermark
      final pageTheme = pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        buildBackground: (pw.Context context) => _buildWatermark(logoImage),
      );

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          header: (pw.Context context) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total Torque Express & Spares Hub',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '+263772790000 +263718177002',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.Text(
                      'mishecktawanda@gmail.com',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
                pw.Container(
                  height: 50,
                  width: 50,
                  child: pw.Image(logoImage),
                ),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(color: PdfColors.blue800),
                pw.SizedBox(height: 10),
                pw.Text(
                  'We take pride in your business with us. Thank you!',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            );
          },
          build: (pw.Context context) => [
            // Main Content Column
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Bill To & Invoice Information
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bill To',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            companyName,
                            style: pw.TextStyle(font: font, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Invoice',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text(
                          'Invoice No: $invoiceNumber',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                        pw.Text(
                          'Date: ${_formatDate(date)}',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                        pw.Text(
                          'Due Date: ${_formatDate(dueDate)}',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                        pw.Text(
                          'Reference: $reference',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.blue100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'No',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Product',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Quantity',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rate',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Table Items
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              item['product'],
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${item['quantity']}',
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _formatCurrency(item['rate'].toDouble()),
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _formatCurrency(item['amount'].toDouble()),
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Paid Items Section
                if (paidItems.isNotEmpty) ...[
                  pw.Text(
                    'Paid Items',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(4),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      // Paid Items Table Header
                      pw.TableRow(
                        decoration:
                        pw.BoxDecoration(color: PdfColors.green100),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'No',
                              style: pw.TextStyle(
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Product',
                              style: pw.TextStyle(
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Quantity',
                              style: pw.TextStyle(
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Amount Paid',
                              style: pw.TextStyle(
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Paid Items Rows
                      ...paidItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${index + 1}',
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                item['product'],
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${item['quantity']}',
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                _formatCurrency(item['amountPaid'].toDouble()),
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
                pw.SizedBox(height: 20),

                // Subtotal, Paid Amount, and Balance Due
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Subtotal:',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            _formatCurrency(amount),
                            style: pw.TextStyle(font: font),
                          ),
                        ],
                      ),
                      if (paidAmount > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Paid Amount:',
                              style: pw.TextStyle(
                                font: font,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(
                              _formatCurrency(paidAmount),
                              style: pw.TextStyle(
                                font: font,
                                color: PdfColors.green800,
                              ),
                            ),
                          ],
                        ),
                      ],
                      pw.Divider(color: PdfColors.grey400),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Balance Due:',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Text(
                            _formatCurrency(amount - paidAmount),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Payment Details
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Details',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Payable To: $accountName',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                      pw.Text(
                        'Bank: $bankName',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                      pw.Text(
                        'Account No: $accountNumber',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Signature Section
                if (signature != null)
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          height: 35,
                          width: 100,
                          child: pw.Image(
                            pw.MemoryImage(signature),
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Authorized Signature',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          authorizedName,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

      // Save the PDF into the documents directory.
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/invoice_${invoiceNumber.replaceAll('/', '_')}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }
}
