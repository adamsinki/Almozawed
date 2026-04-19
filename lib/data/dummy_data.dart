import '../models/app_models.dart';

class DummyData {
  static final List<ProvisionItem> provisions = [
    // Fresh Produce
    ProvisionItem(id: 'p1', nameEn: 'Apples Fresh', nameAr: 'تفاح طازج', price: 2.5, unit: 'kg'),
    ProvisionItem(id: 'p2', nameEn: 'Bananas', nameAr: 'موز', price: 1.8, unit: 'kg'),
    ProvisionItem(id: 'p11', nameEn: 'Oranges', nameAr: 'برتقال', price: 2.0, unit: 'kg'),
    ProvisionItem(id: 'p12', nameEn: 'Tomatoes', nameAr: 'طماطم', price: 1.5, unit: 'kg'),
    ProvisionItem(id: 'p13', nameEn: 'Potatoes', nameAr: 'بطاطس', price: 1.2, unit: 'kg'),
    ProvisionItem(id: 'p14', nameEn: 'Onions', nameAr: 'بصل', price: 1.0, unit: 'kg'),
    
    // Meats
    ProvisionItem(id: 'p3', nameEn: 'Chicken Breast (Frozen)', nameAr: 'صدور دجاج (مجمدة)', price: 5.0, unit: 'kg'),
    ProvisionItem(id: 'p4', nameEn: 'Beef Steak', nameAr: 'شريحة لحم بقري', price: 12.0, unit: 'kg'),
    ProvisionItem(id: 'p15', nameEn: 'Lamb Chops', nameAr: 'ريش غنم', price: 15.0, unit: 'kg'),
    ProvisionItem(id: 'p16', nameEn: 'Minced Beef', nameAr: 'لحم بقري مفروم', price: 9.0, unit: 'kg'),
    
    // Dairy & Eggs
    ProvisionItem(id: 'p5', nameEn: 'Eggs (Tray of 30)', nameAr: 'بيض (طبق 30)', price: 6.5, unit: 'tray'),
    ProvisionItem(id: 'p6', nameEn: 'Milk (Full Fat)', nameAr: 'حليب (كامل الدسم)', price: 1.2, unit: 'L'),
    ProvisionItem(id: 'p17', nameEn: 'Butter (Unsalted)', nameAr: 'زبدة (غير مملحة)', price: 4.5, unit: 'pack'),
    ProvisionItem(id: 'p18', nameEn: 'Cheddar Cheese', nameAr: 'جبنة شيدر', price: 8.0, unit: 'kg'),
    
    // Dry Stores
    ProvisionItem(id: 'p7', nameEn: 'Rice (Basmati)', nameAr: 'أرز (بسمتي)', price: 1.5, unit: 'kg'),
    ProvisionItem(id: 'p8', nameEn: 'Flour', nameAr: 'دقيق', price: 0.8, unit: 'kg'),
    ProvisionItem(id: 'p9', nameEn: 'Sugar', nameAr: 'سكر', price: 1.0, unit: 'kg'),
    ProvisionItem(id: 'p10', nameEn: 'Salt', nameAr: 'ملح', price: 0.5, unit: 'kg'),
    ProvisionItem(id: 'p19', nameEn: 'Pasta (Spaghetti)', nameAr: 'مكرونة (سباغيتي)', price: 1.2, unit: 'pack'),
    ProvisionItem(id: 'p20', nameEn: 'Cooking Oil', nameAr: 'زيت طهي', price: 3.5, unit: 'L'),
  ];

  static Map<String, List<ProvisionItem>> getGroupedProvisions(bool isEnglish) {
    if (isEnglish) {
      return {
        'Fresh Produce': provisions.where((p) => ['p1', 'p2', 'p11', 'p12', 'p13', 'p14'].contains(p.id)).toList(),
        'Meats': provisions.where((p) => ['p3', 'p4', 'p15', 'p16'].contains(p.id)).toList(),
        'Dairy & Eggs': provisions.where((p) => ['p5', 'p6', 'p17', 'p18'].contains(p.id)).toList(),
        'Dry Stores': provisions.where((p) => ['p7', 'p8', 'p9', 'p10', 'p19', 'p20'].contains(p.id)).toList(),
      };
    } else {
      return {
        'منتجات طازجة': provisions.where((p) => ['p1', 'p2', 'p11', 'p12', 'p13', 'p14'].contains(p.id)).toList(),
        'لحوم': provisions.where((p) => ['p3', 'p4', 'p15', 'p16'].contains(p.id)).toList(),
        'ألبان وبيض': provisions.where((p) => ['p5', 'p6', 'p17', 'p18'].contains(p.id)).toList(),
        'مواد جافة': provisions.where((p) => ['p7', 'p8', 'p9', 'p10', 'p19', 'p20'].contains(p.id)).toList(),
      };
    }
  }
}
