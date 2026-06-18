import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class InvoiceGenerator {
  /// Generate invoice PDF
  static Future<Uint8List> generateInvoicePDF({
    required String bookingId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String hallName,
    required String hallLocation,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required int numberOfGuests,
    required double hallPrice,
    required double totalAmount,
    required double advanceAmount,
    required String eventType,
    required bool catering,
    required bool decoration,
    required bool photography,
    required String? specialRequests,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'WEDDING HALL BOOKING',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Invoice & Booking Confirmation',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Booking ID: $bookingId',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              /// CUSTOMER INFO & BOOKING DATE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// CUSTOMER DETAILS
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Customer Information',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Name: $customerName',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Email: $customerEmail',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Phone: $customerPhone',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),

                  /// BOOKING DATE
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Event Details',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Event Date: ${_formatDate(bookingDate)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Time: $startTime - $endTime',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Event Type: ${_capitalizeFirst(eventType)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Guests: $numberOfGuests',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              /// HALL INFORMATION
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hall Information',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Hall Name: $hallName',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Location: $hallLocation',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              /// SERVICES & ADD-ONS
              if (catering || decoration || photography)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Selected Services',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (catering)
                      pw.Text(
                        '✓ Catering Required',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (decoration)
                      pw.Text(
                        '✓ Decoration Required',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (photography)
                      pw.Text(
                        '✓ Photography/Videography',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    pw.SizedBox(height: 12),
                  ],
                ),

              if (specialRequests != null && specialRequests.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Special Requests',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      specialRequests,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 12),
                  ],
                ),

              pw.Divider(),
              pw.SizedBox(height: 20),

              /// PRICING TABLE
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.SizedBox(
                      width: 300,
                      child: _buildPricingTable(
                        hallPrice: hallPrice,
                        catering: catering,
                        decoration: decoration,
                        photography: photography,
                        totalAmount: totalAmount,
                        advanceAmount: advanceAmount,
                      )),
                ],
              ),

              pw.SizedBox(height: 30),

              /// TERMS & CONDITIONS
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terms & Conditions',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '1. Advance amount of 20% is required to confirm the booking.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    '2. Remaining balance must be paid 7 days before the event.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    '3. Cancellation policy applies as per hall terms.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    '4. In case of any changes, notify at least 3 days in advance.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              /// FOOTER
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text(
                'Thank you for choosing our wedding hall. For any queries, please contact us.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build pricing table
  static pw.Widget _buildPricingTable({
    required double hallPrice,
    required bool catering,
    required bool decoration,
    required bool photography,
    required double totalAmount,
    required double advanceAmount,
  }) {
    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.grey300),
      ),
      children: [
        /// Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Description',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),

        /// Hall Price
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Hall Base Price'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '₹${hallPrice.toStringAsFixed(0)}',
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),

        /// Catering
        if (catering)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Catering'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '₹15,000',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),

        /// Decoration
        if (decoration)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Decoration'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '₹10,000',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),

        /// Photography
        if (photography)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Photography/Videography'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '₹5,000',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),

        /// Total Amount
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Total Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),

        /// Advance Amount
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Advance Amount (20%)'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '₹${advanceAmount.toStringAsFixed(0)}',
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),

        /// Balance Amount
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor(0.9, 0.9, 0.9),
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Balance Due',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '₹${(totalAmount - advanceAmount).toStringAsFixed(0)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Format date
  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Capitalize first letter
  static String _capitalizeFirst(String text) {
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Print/Share PDF
  static Future<void> printPDF(Uint8List pdfData, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfData,
      name: fileName,
    );
  }
}
