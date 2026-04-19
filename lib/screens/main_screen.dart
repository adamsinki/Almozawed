import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'provisions_screen.dart';
import 'spare_parts_screen.dart';
import 'services_screen.dart';
import 'my_orders_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Almozawed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const Spacer(),
            if (auth.currentUser != null)
              Text(
                auth.currentUser!.shipName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Sign Out",
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildMenuCard(
                context, "Provisions",
                Icons.shopping_basket_rounded,
                "Order food & consumables",
                const Color(0xFF2C5364),
                const ProvisionsScreen(),
              ),
              _buildMenuCard(
                context, "Spare Parts",
                Icons.settings,
                "Request mechanical parts",
                const Color(0xFF1B5E20),
                const SparePartsScreen(),
              ),
              _buildMenuCard(
                context, "Other Services",
                Icons.miscellaneous_services,
                "Water, bunkering & more",
                const Color(0xFF4A148C),
                const ServicesScreen(),
              ),
              _buildMenuCard(
                context, "My Orders",
                Icons.history_rounded,
                "Track your submissions",
                const Color(0xFFBF360C),
                const MyOrdersScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, String subtitle, Color color, Widget target) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width: 
        // On very small screens (mobile), take most of the width.
        // On larger screens, use a fixed size.
        double screenWidth = MediaQuery.of(context).size.width;
        double cardWidth = screenWidth < 600 ? (screenWidth - 48) : 260;
        
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
          child: Container(
            width: cardWidth,
            height: screenWidth < 600 ? 180 : 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth < 600 ? 15 : 20),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: screenWidth < 600 ? 36 : 48, color: color),
                ),
                SizedBox(height: screenWidth < 600 ? 12 : 16),
                Text(title, style: TextStyle(fontSize: screenWidth < 600 ? 18 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F2027))),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
