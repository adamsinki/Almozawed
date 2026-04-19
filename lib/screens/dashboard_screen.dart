import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isLoginState = true;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController pass2Ctrl = TextEditingController();
  final TextEditingController shipCtrl = TextEditingController();
  final TextEditingController imoCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    shipCtrl.dispose();
    imoCtrl.dispose();
    countryCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusColor: Colors.blueAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Gradient
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.5 + (_bgAnim.value * 0.1), 1.0],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 800;

                if (isMobile) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Almozawed",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Premium Ship Provisions & Services",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          _buildAuthCard(authProvider, isMobile: true),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left Panel: Company Info
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Almozawed",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Your trusted partner in premium ship provisions, spare parts, and comprehensive maritime services.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Serving the global fleet with excellence.",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      
                          // Right Panel: Auth / Place Order Card
                          Expanded(
                            flex: 1,
                            child: Center(child: _buildAuthCard(authProvider)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(AuthProvider authProvider, {bool isMobile = false}) {
    return Container(
      key: const ValueKey('auth_card'),
      constraints: const BoxConstraints(maxWidth: 400),
      height: isMobile ? null : 620,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isLoginState ? "Welcome Back" : "Create Account",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2027),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          if (isMobile)
            ...[
              _buildTextField("Email", emailCtrl, icon: Icons.email),
              if (!isLoginState) ...[
                _buildTextField("Ship Name", shipCtrl, icon: Icons.directions_boat),
                _buildTextField("IMO Number", imoCtrl, icon: Icons.numbers),
                _buildTextField("Country of Origin", countryCtrl, icon: Icons.flag),
                _buildTextField("WhatsApp Phone (Optional)", phoneCtrl, icon: Icons.phone),
              ],
              _buildTextField("Password", passCtrl, obscure: true, icon: Icons.lock),
              if (!isLoginState)
                _buildTextField("Confirm Password", pass2Ctrl, obscure: true, icon: Icons.lock_outline),
            ]
          else
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(), // Card has fixed height on desktop
                children: [
                  _buildTextField("Email", emailCtrl, icon: Icons.email),
                  if (!isLoginState) ...[
                    _buildTextField(
                      "Ship Name",
                      shipCtrl,
                      icon: Icons.directions_boat,
                    ),
                    _buildTextField("IMO Number", imoCtrl, icon: Icons.numbers),
                    _buildTextField(
                      "Country of Origin",
                      countryCtrl,
                      icon: Icons.flag,
                    ),
                    _buildTextField(
                      "WhatsApp Phone (Optional)",
                      phoneCtrl,
                      icon: Icons.phone,
                    ),
                  ],
                  _buildTextField(
                    "Password",
                    passCtrl,
                    obscure: true,
                    icon: Icons.lock,
                  ),
                  if (!isLoginState)
                    _buildTextField(
                      "Confirm Password",
                      pass2Ctrl,
                      obscure: true,
                      icon: Icons.lock_outline,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (authProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5364),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleAuth(authProvider),
              child: Text(
                isLoginState ? "Login" : "Register",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => isLoginState = !isLoginState),
            child: Text(
              isLoginState
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Login",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuth(AuthProvider authProvider) async {
    try {
      if (isLoginState) {
        await authProvider.login(emailCtrl.text, passCtrl.text);
      } else {
        if (passCtrl.text != pass2Ctrl.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match")),
          );
          return;
        }
        await authProvider.register(
          email: emailCtrl.text,
          password: passCtrl.text,
          shipName: shipCtrl.text,
          imoNumber: imoCtrl.text,
          country: countryCtrl.text,
          phoneWhatsapp: phoneCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
