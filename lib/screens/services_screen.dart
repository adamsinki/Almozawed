import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _serviceTypes = [
    {'type': 'Fresh Water Request', 'icon': Icons.water_drop, 'color': const Color(0xFF2196F3)},
    {'type': 'Waste Disposal', 'icon': Icons.delete_outline, 'color': const Color(0xFF795548)},
    {'type': 'Sludge Disposal', 'icon': Icons.oil_barrel, 'color': const Color(0xFF607D8B)},
    {'type': 'Bunkering Request', 'icon': Icons.local_gas_station, 'color': const Color(0xFFFF9800)},
    {'type': 'Custom Request', 'icon': Icons.add_box_outlined, 'color': const Color(0xFF9C27B0)},
  ];

  void _showServiceDialog(BuildContext context, String userId, String serviceType, IconData icon, Color color) {
    DateTime? selectedDate;
    final detailsCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
                const SizedBox(width: 12),
                Expanded(child: Text(serviceType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arrival Date Picker
                  const Text("Arrival / Required Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate == null
                                ? "Select arrival date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: TextStyle(
                              color: selectedDate == null ? Colors.grey : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Additional details
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Additional Details (optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an arrival date")));
                          return;
                        }
                        setModalState(() => isSubmitting = true);
                        try {
                          await _firestore.collection('service_requests').add({
                            'user_id': userId,
                            'type': serviceType,
                            'arrival_date': selectedDate!.toIso8601String(),
                            'details': detailsCtrl.text,
                            'status': 'pending',
                            'created_at': DateTime.now().toIso8601String(),
                          });
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$serviceType submitted successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setModalState(() => isSubmitting = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Submit Request"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Other Services"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("Select a Service", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F2027))),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("Submit a service request and our team will get back to you.", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _serviceTypes.length,
            itemBuilder: (ctx, i) {
              final svc = _serviceTypes[i];
              final color = svc['color'] as Color;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showServiceDialog(context, userId, svc['type'], svc['icon'], color),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(svc['icon'] as IconData, size: 40, color: color),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          svc['type'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F2027)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Past requests section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("My Service Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('service_requests')
                .where('user_id', isEqualTo: userId)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text("No service requests yet.", style: TextStyle(color: Colors.grey))),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snap.data!.docs.length,
                itemBuilder: (_, i) {
                  final d = snap.data!.docs[i].data() as Map<String, dynamic>;
                  final status = d['status'] ?? 'pending';
                  final arrDate = d['arrival_date'] != null
                      ? DateTime.tryParse(d['arrival_date'])
                      : null;
                  Color statusColor;
                  switch (status) {
                    case 'accepted': statusColor = Colors.green; break;
                    case 'declined': statusColor = Colors.red; break;
                    case 'complete': statusColor = Colors.blue; break;
                    default: statusColor = Colors.orange;
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(d['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(arrDate != null
                          ? "Arrival: ${arrDate.day}/${arrDate.month}/${arrDate.year}"
                          : ""),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
