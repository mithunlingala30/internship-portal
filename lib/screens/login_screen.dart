import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message ?? 'Authentication failed';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
          errorMessage = 'Invalid email or password';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double headerHeight = constraints.maxHeight * 0.4;
          final double clampedHeaderHeight =
              headerHeight < 280.0 ? 280.0 : (headerHeight > 400.0 ? 400.0 : headerHeight);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // Top Banner Background
                    Container(
                      height: clampedHeaderHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'master_4k.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue your internship journey',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Form Content
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: clampedHeaderHeight - 60,
                          left: 20,
                          right: 20,
                          bottom: 40,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 450),
                              decoration: AppDecorations.cardDecoration.copyWith(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildLabel('Email Address'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _emailController,
                                    hint: 'your@email.com',
                                    icon: Icons.email_outlined,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildLabel('Password'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white, strokeWidth: 2.5))
                                          : const Text('Sign In',
                                              style: AppTextStyles.buttonText),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.label);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: AppDecorations.inputDecoration,
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
