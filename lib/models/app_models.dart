class UserModel {
  final String uid;
  final String email;
  final String shipName;
  final String imoNumber;
  final String country;
  final String phoneWhatsapp;
  final String role; // 'user' or 'staff'

  UserModel({
    required this.uid,
    required this.email,
    required this.shipName,
    required this.imoNumber,
    required this.country,
    required this.phoneWhatsapp,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      shipName: data['ship_name'] ?? '',
      imoNumber: data['imo_number'] ?? '',
      country: data['country'] ?? '',
      phoneWhatsapp: data['phone_whatsapp'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'ship_name': shipName,
      'imo_number': imoNumber,
      'country': country,
      'phone_whatsapp': phoneWhatsapp,
      'role': role,
    };
  }
}

class ProvisionItem {
  final String id;
  final String nameEn;
  final String nameAr;
  final double price;
  final String unit;
  final String? imageUrl;

  ProvisionItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.unit,
    this.imageUrl,
  });
}

class CartItem {
  final ProvisionItem provision;
  int quantity;
  String note;

  CartItem({
    required this.provision,
    this.quantity = 1,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': provision.id,
      'name_en': provision.nameEn,
      'name_ar': provision.nameAr,
      'price': provision.price,
      'unit': provision.unit,
      'quantity': quantity,
      'note': note,
    };
  }
}

class CustomRequest {
  final String name;
  final int quantity;
  final String description;
  String status; // 'pending', 'accepted', 'declined'
  double? proposedPrice;
  String adminNote;

  CustomRequest({
    required this.name,
    required this.quantity,
    required this.description,
    this.status = 'pending',
    this.proposedPrice,
    this.adminNote = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'description': description,
      'status': status,
      'proposed_price': proposedPrice,
      'admin_note': adminNote,
    };
  }

  factory CustomRequest.fromMap(Map<String, dynamic> map) {
    return CustomRequest(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      proposedPrice: map['proposed_price'],
      adminNote: map['admin_note'] ?? '',
    );
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final DateTime date;
  final String status; // 'pending', 'accepted', 'declined', 'complete'
  final List<CartItem> items;
  final List<CustomRequest> customProvisions;
  final double total;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.date,
    required this.status,
    required this.items,
    required this.customProvisions,
    required this.total,
  });
}

class SparePartRequest {
  final String id;
  final String userId;
  final String description;
  final List<String> imageUrls;
  final String status;
  final double? proposedPrice;

  SparePartRequest({
    required this.id,
    required this.userId,
    required this.description,
    required this.imageUrls,
    required this.status,
    this.proposedPrice,
  });
}

class ServiceRequest {
  final String id;
  final String userId;
  final String type; // 'Fresh water', 'Waste disposal', 'Sludge disposal', 'Bunkering', 'Custom'
  final DateTime arrivalDate;
  final String? details;
  final String status;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.arrivalDate,
    required this.status,
    this.details,
  });
}
