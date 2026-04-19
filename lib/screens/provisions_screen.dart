import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/order_provider.dart';
import '../models/app_models.dart';
import '../data/dummy_data.dart';
import 'order_summary_screen.dart';

class ProvisionsScreen extends StatefulWidget {
  const ProvisionsScreen({super.key});

  @override
  State<ProvisionsScreen> createState() => _ProvisionsScreenState();
}

class _ProvisionsScreenState extends State<ProvisionsScreen> {
  final Map<String, bool> _expanded = {};

  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _customQtyCtrl = TextEditingController();
  final TextEditingController _customDescCtrl = TextEditingController();

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customQtyCtrl.dispose();
    _customDescCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final groupedData = DummyData.getGroupedProvisions(localeProvider.isEnglish);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(localeProvider.isEnglish ? "Provisions" : "المؤن"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => localeProvider.toggleLanguage(),
            child: Text(localeProvider.isEnglish ? "عربي" : "EN", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = MediaQuery.of(context).size.width < 500;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364), foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderSummaryScreen()));
                  },
                  icon: const Icon(Icons.check),
                  label: isSmall ? const Text("") : Text(localeProvider.isEnglish ? "Complete Request" : "إتمام الطلب"),
                ),
              );
            }
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...groupedData.entries.map((entry) => _buildCategorySection(entry.key, entry.value, localeProvider, orderProvider)),
                
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                
                // Other Request Section at Bottom
                Text(
                  localeProvider.isEnglish ? "Other Request (Not in list)" : "طلب آخر (غير موجود بالقائمة)",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 45,
                                child: TextField(
                                  controller: _customNameCtrl,
                                  decoration: InputDecoration(
                                    labelText: localeProvider.isEnglish ? "Item Name" : "اسم الصنف",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              height: 45,
                              child: TextField(
                                controller: _customQtyCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: localeProvider.isEnglish ? "Qty" : "الكمية",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: TextField(
                                  controller: _customDescCtrl,
                                  decoration: InputDecoration(
                                    labelText: localeProvider.isEnglish ? "Description / Note" : "الوصف / ملاحظة",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                if (_customNameCtrl.text.isNotEmpty && _customQtyCtrl.text.isNotEmpty) {
                                  orderProvider.addCustomRequest(
                                    _customNameCtrl.text,
                                    int.tryParse(_customQtyCtrl.text) ?? 1,
                                    _customDescCtrl.text,
                                  );
                                  _customNameCtrl.clear();
                                  _customQtyCtrl.clear();
                                  _customDescCtrl.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Custom item added!")));
                                }
                              },
                              icon: const Icon(Icons.add_circle, color: Color(0xFF2C5364), size: 40),
                            )
                          ],
                        ),
                        
                        // New: List of added items
                        if (orderProvider.customRequests.isNotEmpty) ...[
                          const Divider(height: 32),
                          ...orderProvider.customRequests.map((req) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          "${localeProvider.isEnglish ? 'Qty' : 'الكمية'}: ${req.quantity} | ${req.description}",
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => orderProvider.removeCustomRequest(req),
                                  )
                                ],
                              ),
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // Bottom Bar Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localeProvider.isEnglish ? "Total Estimate:" : "الإجمالي التقديري:",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\$${orderProvider.total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C5364)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ProvisionItem> items, LocaleProvider loc, OrderProvider prov) {
    bool expanded = _expanded[category] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _expanded[category] = !expanded;
              });
            },
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: items.map((item) => _buildProvisionLine(item, loc, prov)).toList(),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildProvisionLine(ProvisionItem item, LocaleProvider loc, OrderProvider prov) {
    int qty = prov.getQuantity(item);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.blueGrey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.isEnglish ? item.nameEn : item.nameAr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      " / ${item.unit}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: loc.isEnglish ? "Qty" : "الكمية",
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: TextEditingController(text: qty > 0 ? qty.toString() : '')
                          ..selection = TextSelection.fromPosition(TextPosition(offset: (qty > 0 ? qty.toString().length : 0))),
                        onChanged: (val) {
                          int newQty = int.tryParse(val) ?? 0;
                          prov.updateQuantity(item, newQty);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: loc.isEnglish ? "Note..." : "ملاحظة...",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (val) {
                            if (qty > 0) prov.updateNote(item, val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_grocery_store, color: Colors.blueGrey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.isEnglish ? item.nameEn : item.nameAr,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          "\$${item.price.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          " / ${item.unit}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 35,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: loc.isEnglish ? "Qty" : "الكمية",
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  controller: TextEditingController(text: qty > 0 ? qty.toString() : '')
                    ..selection = TextSelection.fromPosition(TextPosition(offset: (qty > 0 ? qty.toString().length : 0))),
                  onChanged: (val) {
                    int newQty = int.tryParse(val) ?? 0;
                    prov.updateQuantity(item, newQty);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 35,
                  child: TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: loc.isEnglish ? "Note..." : "ملاحظة...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (val) {
                      if (qty > 0) prov.updateNote(item, val);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
