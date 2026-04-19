import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static Future<void> printOrder(Map<String, dynamic> data) async {
    final doc = pw.Document();
    
    // Load fonts for better character support (including Arabic)
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final baseFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final dateStr = data['date'] ?? '';
    final formattedDate = dateStr.isNotEmpty 
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(dateStr))
        : 'N/A';
        
    final status = (data['status'] ?? 'pending').toString().toUpperCase();
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final customItems = List<Map<String, dynamic>>.from(data['custom_provisions'] ?? []);
    final total = (data['total'] ?? 0.0).toDouble();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: baseFont,
          bold: boldFont,
          fontFallback: [arabicFont],
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Almozawed Provisions System', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                    pw.Text('Order Receipt', style: pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date: $formattedDate'),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text('Status: $status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Provisions Table
            if (items.isNotEmpty) ...[
              pw.Text('Provisions List', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  ...items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item['name_en'] ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item['quantity'].toString(), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item['unit'] ?? '', textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('\$${(item['price'] ?? 0.0).toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Custom Requests
            if (customItems.isNotEmpty) ...[
              pw.Text('Custom Requests', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              ...customItems.map((req) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.TableBorder.all(color: PdfColors.grey200)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(req['name'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty: ${req['quantity'] ?? 1}'),
                      ],
                    ),
                    pw.Text(req['description'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    if (req['proposed_price'] != null)
                      pw.Text('Proposed Price: \$${req['proposed_price'].toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.green)),
                  ],
                ),
              )),
              pw.SizedBox(height: 20),
            ],

            pw.Divider(thickness: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Estimate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Center(child: pw.Text('Thank you for choosing Almozawed Provisions System', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500))),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
