import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<CartItem> _cartItems = [];
  final List<CustomRequest> _customRequests = [];

  List<CartItem> get cartItems => _cartItems;
  List<CustomRequest> get customRequests => _customRequests;

  double get total {
    double sum = 0;
    for (var item in _cartItems) {
      sum += item.provision.price * item.quantity;
    }
    return sum;
  }

  void updateQuantity(ProvisionItem provision, int quantity) {
    if (quantity <= 0) {
      _cartItems.removeWhere((item) => item.provision.id == provision.id);
    } else {
      var existing = _cartItems.where((item) => item.provision.id == provision.id).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity = quantity;
      } else {
        _cartItems.add(CartItem(provision: provision, quantity: quantity));
      }
    }
    notifyListeners();
  }

  void updateNote(ProvisionItem provision, String note) {
    var existing = _cartItems.where((item) => item.provision.id == provision.id).toList();
    if (existing.isNotEmpty) {
      existing.first.note = note;
    }
    notifyListeners();
  }

  int getQuantity(ProvisionItem provision) {
    var existing = _cartItems.where((item) => item.provision.id == provision.id).toList();
    if (existing.isNotEmpty) {
      return existing.first.quantity;
    }
    return 0;
  }

  void addCustomRequest(String name, int quantity, String description) {
    _customRequests.add(CustomRequest(
      name: name,
      quantity: quantity,
      description: description,
    ));
    notifyListeners();
  }

  void removeCustomRequest(CustomRequest request) {
    _customRequests.remove(request);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _customRequests.clear();
    notifyListeners();
  }

  Future<void> submitOrder(String userId) async {
    final orderId = _firestore.collection('orders').doc().id;
    
    // Save custom requests
    List<Map<String, dynamic>> customReqMaps = [];
    for (var req in _customRequests) {
      final customDoc = _firestore.collection('custom_provisions').doc();
      final reqMap = req.toMap();
      reqMap['user_id'] = userId;
      reqMap['order_id'] = orderId;
      await customDoc.set(reqMap);
      customReqMaps.add(reqMap);
    }

    // Save order
    await _firestore.collection('orders').doc(orderId).set({
      'user_id': userId,
      'date': DateTime.now().toIso8601String(),
      'status': 'pending',
      'total': total,
      'items': _cartItems.map((e) => e.toMap()).toList(),
      'custom_provisions': customReqMaps,
    });

    clearCart();
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore.collection('orders')
        .where('user_id', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
