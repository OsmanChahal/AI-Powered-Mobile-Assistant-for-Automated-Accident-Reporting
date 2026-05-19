import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  /// When true, the screen is shown after a Google sign-in and hides
  /// the email / password fields. The Google user's name and email are
  /// pre-filled automatically.
  final bool isGoogleSignUp;
  final String? googleFirstName;
  final String? googleLastName;
  final String? googleEmail;

  const RegisterScreen({
    super.key,
    this.isGoogleSignUp = false,
    this.googleFirstName,
    this.googleLastName,
    this.googleEmail,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _carModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _insuranceController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields from Google account data
    if (widget.isGoogleSignUp) {
      _firstNameController.text = widget.googleFirstName ?? '';
      _lastNameController.text = widget.googleLastName ?? '';
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue600,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birthdate.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isGoogleSignUp) {
        // Google sign-up: user is already authenticated, just save the profile
        await AuthService.completeGoogleProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          birthdate: _selectedDate!,
          carModel: _carModelController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          insuranceCompany: _insuranceController.text.trim(),
        );
      } else {
        // Normal email/password registration
        await AuthService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          birthdate: _selectedDate!,
          carModel: _carModelController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          insuranceCompany: _insuranceController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.teal400,
          ),
        );

        if (widget.isGoogleSignUp) {
          // For Google sign-up, navigate to home (AuthWrapper will handle it)
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          // We pop the register screen.
          // The auth wrapper will pick up the auth state change and send us to Home.
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.message ?? 'Registration failed. Please try again.'),
            backgroundColor: AppColors.red400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: AppColors.red400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _carModelController.dispose();
    _licensePlateController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isGoogleSignUp ? 'Complete Your Profile' : 'Create Account'),
        leading: widget.isGoogleSignUp
            ? null // No back button for Google sign-up (they must complete the form)
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        automaticallyImplyLeading: !widget.isGoogleSignUp,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Show a welcome message for Google sign-up
                      if (widget.isGoogleSignUp) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.blue600.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.blue600.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.blue600),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blue800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Signed in as ${widget.googleEmail}.\nPlease complete your profile to continue.',
                                      style: TextStyle(
                                        color:
                                            AppColors.blue800.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      const Text(
                        'Personal Information',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue800),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person_outline,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person_outline,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? 'Birthdate'
                                    : DateFormat.yMMMd().format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade700
                                      : AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Only show email & password fields for normal (non-Google) registration
                      if (!widget.isGoogleSignUp) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Account Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue800),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val == null || !val.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (val) => val == null || val.length < 6
                              ? 'Min 6 characters required'
                              : null,
                        ),
                      ],

                      const SizedBox(height: 32),
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue800),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _carModelController,
                        label: 'Car Model',
                        icon: Icons.directions_car_outlined,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _licensePlateController,
                        label: 'License Plate',
                        icon: Icons.pin_outlined,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _insuranceController,
                        label: 'Insurance Company (Optional)',
                        icon: Icons.verified_user_outlined,
                        validator: null,
                      ),

                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: widget.isGoogleSignUp
                            ? 'Complete Profile'
                            : 'Create Account',
                        onTap: _handleRegister,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
