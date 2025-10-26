import 'package:flutter/material.dart';

// Import local files
import 'main_navigation_screen.dart';

// --- Helper for TextFields (Used on both Login and Sign Up) ---
InputDecoration minimalistInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: Colors.indigo.shade400,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(icon, color: Colors.indigo.shade400),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
    ),
    filled: true,
    fillColor: Colors.indigo.shade50.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
  );
}

// --- Login Page Widget ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey for Form validation
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() {
    // 1. Validate the form inputs
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Navigating to main app...'),
        ),
      );
      // Navigate to Main App screen and remove Login from history
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const MainNavigationScreen(),
        ),
      );
    } else {
      // Validation failed, errors are shown by the TextFormField widgets
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors above.')),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E2DE2), // Light Purple
              Color(0xFF4A00E0), // Deep Violet
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Budget Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 80),
                _buildLoginForm(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _navigateToSignUp,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    // Wrap the form inputs in a Form widget for validation
    return Form(
      key: _loginFormKey,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userIdController,
              keyboardType: TextInputType.emailAddress,
              decoration: minimalistInputDecoration(
                label: 'User ID / Email',
                icon: Icons.person_outline,
              ),
              style: const TextStyle(color: Colors.black87),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required.';
                }
                // Simple email format check
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: minimalistInputDecoration(
                label: 'Password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.indigo.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.black87),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'LOG IN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// --- Reusable Social Login Button Widget ---
class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const SocialLoginButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// --- Sign Up Page Widget ---
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // GlobalKey for Form validation
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleEmailSignUp() {
    // 1. Validate the form inputs
    if (_signUpFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign Up successful! Navigating to main app...'),
        ),
      );
      // Navigate to Main App screen and remove Sign Up from history
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const MainNavigationScreen(),
        ),
      );
    } else {
      // Validation failed, errors are shown by the TextFormField widgets
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors above.')),
      );
    }
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Signing up with $provider...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E2DE2), // Light Purple
              Color(0xFF4A00E0), // Deep Violet
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Join Budget Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Social Login Options ---
                      SocialLoginButton(
                        label: 'Sign Up with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: () => _handleSocialLogin('Google'),
                        backgroundColor: const Color(0xFFDB4437),
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        label: 'Sign Up with Facebook',
                        icon: Icons.facebook,
                        onPressed: () => _handleSocialLogin('Facebook'),
                        backgroundColor: const Color(0xFF4267B2),
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        label: 'Sign Up with Discord',
                        icon: Icons.person_add,
                        onPressed: () => _handleSocialLogin('Discord'),
                        backgroundColor: const Color(0xFF7289DA),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'OR register with email',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Wrap email/password fields in a Form widget
                      Form(
                        key: _signUpFormKey,
                        child: Column(
                          children: [
                            // --- Email Field with Validation ---
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: minimalistInputDecoration(
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                              ),
                              style: const TextStyle(color: Colors.black87),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required for sign up.';
                                }
                                // Robust email format check
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // --- Password Field with Validation ---
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: minimalistInputDecoration(
                                label: 'Create Password',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.indigo.shade400,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: const TextStyle(color: Colors.black87),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required.';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Email Sign Up Button
                      ElevatedButton(
                        onPressed: _handleEmailSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Back to Login Link
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Already have an account? Log In',
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
