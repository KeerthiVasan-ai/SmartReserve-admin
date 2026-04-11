import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_reserve_admin/services/create_user_service.dart';
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _slotsController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    _slotsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await CreateUserService.createUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      staffId: _staffIdController.text.trim(),
      slotsPerWeek: int.parse(_slotsController.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      GCPLog.info('New user account created: ${_nameController.text.trim()} (${_staffIdController.text.trim()})', userId: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User created successfully!',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: const Color(0xFF2D9596),
        ),
      );
      Navigator.pop(context);
    } else {
      GCPLog.error('User creation failed for ${_emailController.text.trim()}', error: error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Create User",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.60)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2D9596).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Color(0xFF2D9596),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'New User',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create an account for a staff member',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name field
                      FormFieldWidget(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_rounded,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter name';
                          if (v.trim().length < 3) return 'Name must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Staff ID field
                      FormFieldWidget(
                        controller: _staffIdController,
                        label: 'Staff ID',
                        icon: Icons.badge_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter staff ID'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Slots per week field
                      FormFieldWidget(
                        controller: _slotsController,
                        label: 'Slots per Week',
                        icon: Icons.event_available_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter number of slots';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email field
                      FormFieldWidget(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter email';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Temp password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          labelText: 'Temporary Password',
                          labelStyle:
                              const TextStyle(color: Color(0xFF124076)),
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF124076)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter password';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Create button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D9596),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'CREATE USER',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF124076)),
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF124076)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      validator: validator,
    );
  }
}
