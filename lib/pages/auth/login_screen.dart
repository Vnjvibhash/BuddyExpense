import 'package:buddyexpense/pages/auth/register_screen.dart';
import 'package:buddyexpense/pages/home_page.dart';
import 'package:buddyexpense/services/auth_service.dart';
import 'package:buddyexpense/theme.dart';
import 'package:buddyexpense/widgets/animated_button.dart';
import 'package:buddyexpense/widgets/login_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _useEmailLogin = false;
  String _verificationId = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter a valid phone number');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) phoneNumber = '+91$phoneNumber';

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await authService.signInWithPhoneCredential(
          verificationId: credential.verificationId ?? _verificationId,
          smsCode: credential.smsCode ?? '',
        );
        if (result != null) _navigateToHome();
      },
      verificationFailed: (e) =>
          _showError(e.message ?? 'Phone verification failed'),
      codeSent: (verificationId, _) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP sent successfully!'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signInWithPhoneCredential(
      verificationId: _verificationId,
      smsCode: _otpController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (result != null) {
      _otpController.clear();
      _navigateToHome();
    } else {
      _showError('Invalid OTP. Please try again.');
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (user != null)
      _navigateToHome();
    else
      _showError("Invalid email or password");
  }

  void _switchLoginMode() {
    setState(() {
      _useEmailLogin = !_useEmailLogin;
      _isOtpSent = false;
      _phoneController.clear();
      _otpController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 800),
        child: const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            center: Alignment.topLeft,
            radius: 2.0,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoginHeader(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                ),
                const SizedBox(height: Spacing.xl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                  child: _useEmailLogin
                      ? _buildEmailLoginForm(cs, key: const ValueKey(1))
                      : _buildLoginForm(cs, key: const ValueKey(2)),
                ),
                const SizedBox(height: Spacing.xl),
                _buildGoogleToEmailSwitcher(cs),
                const SizedBox(height: Spacing.lg),
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 800),
                                child: const RegisterScreen(),
                              ),
                            );
                          },
                    child: Text(
                      'New user? Register here',
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ColorScheme cs, {Key? key}) => AnimatedBuilder(
    key: key,
    animation: _scaleAnimation,
    builder: (context, child) => Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in with Phone',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            if (!_isOtpSent) ...[
              _buildPhoneInput(cs),
              const SizedBox(height: Spacing.lg),
              AnimatedButton(
                label: 'Send OTP',
                icon: Icons.send,
                isLoading: _isLoading,
                onTap: _isLoading ? null : _sendOTP,
                backgroundColor: const Color(0xFF667eea),
              ),
            ] else ...[
              _buildOTPInput(cs),
              const SizedBox(height: Spacing.lg),
              AnimatedButton(
                label: 'Verify OTP',
                icon: Icons.verified,
                isLoading: _isLoading,
                onTap: _isLoading ? null : _verifyOTP,
                backgroundColor: const Color(0xFF4facfe),
              ),
              const SizedBox(height: Spacing.md),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                          });
                        },
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(color: cs.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildEmailLoginForm(ColorScheme cs, {Key? key}) => AnimatedBuilder(
    key: key,
    animation: _scaleAnimation,
    builder: (context, child) => Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in with Email',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            AnimatedButton(
              label: 'Login',
              icon: Icons.login,
              isLoading: _isLoading,
              onTap: _isLoading ? null : _signInWithEmail,
              backgroundColor: cs.primary,
            ),
            // const SizedBox(height: Spacing.lg),
            // Center(
            //   child: TextButton(
            //     onPressed: () => _switchLoginMode(false),
            //     child: Text(
            //       "Login with phone instead",
            //       style: TextStyle(color: cs.primary),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );

  Widget _buildPhoneInput(ColorScheme cs) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Phone Number',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: Spacing.sm),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '1234567890',
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: cs.outline.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildOTPInput(ColorScheme cs) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Enter OTP',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: Spacing.sm),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '123456',
            prefixIcon: Icon(Icons.security, color: cs.primary),
            border: InputBorder.none,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildGoogleToEmailSwitcher(ColorScheme cs) => Column(
    children: [
      Row(
        children: [
          Expanded(child: Divider(color: cs.outline.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(child: Divider(color: cs.outline.withOpacity(0.3))),
        ],
      ),
      const SizedBox(height: Spacing.lg),
      AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedButton(
            label: _useEmailLogin
                ? 'Continue with Phone'
                : 'Continue with E-mail',
            icon: _useEmailLogin ? Icons.phone : Icons.email,
            isLoading: _isLoading,
            backgroundColor: Theme.of(context).colorScheme.surface,
            textColor: Theme.of(context).colorScheme.onSurface,
            onTap: _isLoading
                ? null
                : () => _switchLoginMode(),
          ),
        ),
      ),
    ],
  );
}
