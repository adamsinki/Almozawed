import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'main_screen.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  Future<void> _generatePdf(BuildContext context, OrderProvider provider, AuthProvider auth) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Almozawed Provisions - Order Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Ship: ${auth.currentUser?.shipName ?? "Unknown"}'),
              pw.Text('IMO: ${auth.currentUser?.imoNumber ?? "Unknown"}'),
              pw.Text('Date: ${DateTime.now().toLocal().toString().split('.')[0]}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Unit', 'Price', 'Total', 'Note'],
                data: [
                  ...provider.cartItems.map((item) => [
                        item.provision.nameEn,
                        item.quantity.toString(),
                        item.provision.unit,
                        '\$${item.provision.price.toStringAsFixed(2)}',
                        '\$${(item.provision.price * item.quantity).toStringAsFixed(2)}',
                        item.note,
                      ]),
                  ...provider.customRequests.map((req) => [
                        req.name,
                        req.quantity.toString(),
                        'custom',
                        'TBD',
                        'TBD',
                        req.description,
                      ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Estimated Total (excluding customs): \$${provider.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Order Summary"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: orderProvider.cartItems.isEmpty && orderProvider.customRequests.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text("Provisions List", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...orderProvider.cartItems.map((item) => Card(
                            child: ListTile(
                              title: Text(item.provision.nameEn),
                              subtitle: Text("Qty: ${item.quantity} ${item.provision.unit} | Note: ${item.note}"),
                              trailing: Text("\$${(item.provision.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )),
                      const SizedBox(height: 20),
                      if (orderProvider.customRequests.isNotEmpty) ...[
                        const Text("Other Requests", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...orderProvider.customRequests.map((req) => Card(
                              child: ListTile(
                                title: Text(req.name),
                                subtitle: Text("Qty: ${req.quantity} | Desc: ${req.description}"),
                                trailing: const Text("Price TBD", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              ),
                            )),
                      ]
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Estimate:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("\$${orderProvider.total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C5364))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          bool isSmall = constraints.maxWidth < 500;
                          return isSmall ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text("Download PDF"),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                onPressed: () => _generatePdf(context, orderProvider, authProvider),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                                onPressed: () async {
                                  if (authProvider.currentUser != null) {
                                    try {
                                      await orderProvider.submitOrder(authProvider.currentUser!.uid);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Submitted successfully!")));
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => route.isFirst);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit order: $e"), backgroundColor: Colors.red));
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to order")));
                                  }
                                },
                                child: const Text("Complete Order", style: TextStyle(fontSize: 18)),
                              ),
                            ],
                          ) : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text("Download PDF"),
                                  onPressed: () => _generatePdf(context, orderProvider, authProvider),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                                  onPressed: () async {
                                    if (authProvider.currentUser != null) {
                                      try {
                                        await orderProvider.submitOrder(authProvider.currentUser!.uid);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Submitted successfully!")));
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => route.isFirst);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit order: $e"), backgroundColor: Colors.red));
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to order")));
                                    }
                                  },
                                  child: const Text("Complete Order", style: TextStyle(fontSize: 18)),
                                ),
                              ),
                            ],
                          );
                        }
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
