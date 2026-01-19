import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String _phoneNumber = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Format phone number: +91 + 10 digits
      _phoneNumber = '+91${_phoneController.text.trim()}';
      
      await ref.read(authServiceProvider).sendOTP(_phoneNumber);
      
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      
      // Restart animation for OTP screen
      _animationController.reset();
      _animationController.forward();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('OTP sent successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to send OTP: $error')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Text('Please enter a 6-digit OTP'),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authServiceProvider).verifyOTP(
        _phoneNumber,
        _otpController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Text('Login successful! Welcome back!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Invalid OTP: $error')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          
                          // Logo
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/Logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // App Name
                          const Text(
                            'Near & Now',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Fresh Groceries at Your Doorstep',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // White Card Container
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _otpSent ? Icons.lock_clock : Icons.phone_android,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _otpSent ? 'Verify OTP' : 'Welcome Back!',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _otpSent ? 'Enter the code' : 'Login to continue',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 32),
                                
                                if (!_otpSent) ...[
                                  // Phone Number Section
                                  const Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  CustomTextField(
                                    label: '',
                                    hint: 'Enter your 10-digit mobile number',
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(color: AppColors.border),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '🇮🇳',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '+91',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  CustomButton(
                                    text: 'Send OTP',
                                    onPressed: _sendOTP,
                                    isLoading: _isLoading,
                                    fullWidth: true,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Info Box
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'You\'ll receive a 6-digit OTP on your mobile number',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // OTP Section
                                  Text(
                                    'We sent a code to',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _phoneNumber,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  Center(
                                    child: Pinput(
                                      controller: _otpController,
                                      length: 6,
                                      onCompleted: (pin) => _verifyOTP(),
                                      defaultPinTheme: PinTheme(
                                        width: 50,
                                        height: 60,
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          border: Border.all(color: AppColors.border),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      focusedPinTheme: PinTheme(
                                        width: 50,
                                        height: 60,
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.05),
                                          border: Border.all(color: AppColors.primary, width: 2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      submittedPinTheme: PinTheme(
                                        width: 50,
                                        height: 60,
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  CustomButton(
                                    text: 'Verify & Login',
                                    onPressed: _verifyOTP,
                                    isLoading: _isLoading,
                                    fullWidth: true,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _otpSent = false;
                                            _otpController.clear();
                                          });
                                          _animationController.reset();
                                          _animationController.forward();
                                        },
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Change Number'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.textSecondary,
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 16,
                                        color: AppColors.border,
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      TextButton.icon(
                                        onPressed: _isLoading ? null : _sendOTP,
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: const Text('Resend OTP'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Footer
                          Text(
                            'By continuing, you agree to our Terms & Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
