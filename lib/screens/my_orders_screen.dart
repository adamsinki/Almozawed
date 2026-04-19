import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/pdf_helper.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'declined': return Colors.red;
      case 'complete': return Colors.blue;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle;
      case 'declined': return Icons.cancel;
      case 'complete': return Icons.verified;
      default: return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders")),
        body: const Center(child: Text("Please log in to see your orders.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: auth.currentUser!.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("FIRESTORE ERROR (Orders): ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Error loading orders: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }
          final orders = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final data = orders[i].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final total = (data['total'] ?? 0.0).toDouble();
              final date = data['date'] ?? '';
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
              final customItems = List<Map<String, dynamic>>.from(data['custom_provisions'] ?? []);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(_statusIcon(status), color: _statusColor(status), size: 36),
                  title: Text(
                    "Order - ${date.toString().split('T').first}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.print, color: Color(0xFF2C5364)),
                    onPressed: () => PdfHelper.printOrder(data),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor(status)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C5364), fontSize: 16),
                      ),
                    ],
                  ),
                  children: [
                    if (items.isNotEmpty) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Provisions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ...items.map((item) => ListTile(
                            leading: const Icon(Icons.local_grocery_store, color: Colors.grey),
                            title: Text(item['name_en'] ?? ''),
                            subtitle: Text("Qty: ${item['quantity']} ${item['unit']}${item['note'] != null && item['note'].toString().isNotEmpty ? ' | Note: ${item['note']}' : ''}"),
                            trailing: Text("\$${((item['price'] ?? 0.0) * (item['quantity'] ?? 0)).toStringAsFixed(2)}"),
                          )),
                    ],
                    if (customItems.isNotEmpty) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Custom Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ...customItems.map((req) {
                        final reqStatus = req['status'] ?? 'pending';
                        final isDeclined = reqStatus == 'declined';
                        final adminNote = req['admin_note'] ?? '';
                        final proposedPrice = req['proposed_price'];

                        return ListTile(
                          leading: Icon(
                            isDeclined ? Icons.cancel : Icons.pending_actions,
                            color: isDeclined ? Colors.red : Colors.orange,
                          ),
                          title: Text(req['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Qty: ${req['quantity']} | ${req['description']}"),
                              if (proposedPrice != null)
                                Text("Price: \$${proposedPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green)),
                              if (isDeclined && adminNote.isNotEmpty)
                                Text("DECLINED: $adminNote", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      }),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
