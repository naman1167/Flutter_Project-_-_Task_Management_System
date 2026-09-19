import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Project Lead & Senior Engineer';

  final List<String> _availableRoles = [
    'Project Lead & Senior Engineer',
    'Tech Lead & Architect',
    'Backend & Cloud Specialist',
    'Product Designer (UI/UX)',
    'Fullstack Developer',
    'QA & DevOps Engineer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp &&
        _passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final appState = context.read<AppState>();

    try {
      if (_isSignUp) {
        await appState.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );
      } else {
        await appState.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Authentication error. Please try again.';
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.message?.contains('malformed') == true ||
          e.message?.contains('expired') == true) {
        msg = _isSignUp
            ? 'Registration notice: ${e.message ?? e.code}. You can also use Demo Mode below.'
            : 'This account is not yet created in Firebase. Switch to "Create Account" tab to register, or click Demo Mode below.';
      } else if (e.code == 'wrong-password') {
        msg = 'Incorrect password. Please try again.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'This email is already registered. Please sign in.';
      } else if (e.code == 'invalid-email') {
        msg = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        msg = 'Password should be at least 6 characters.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _quickFillDemo(String email, String role, String name) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'Password123!';
      _confirmPasswordController.text = 'Password123!';
      _nameController.text = name;
      _selectedRole = role;
      _errorMessage = null;
    });
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
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App Branding
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF0EA5E9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.dashboard_customize_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'TaskPulse',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isSignUp
                                ? 'Create your workspace account'
                                : 'Welcome back! Sign in to continue',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Toggle Sign In / Sign Up
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isSignUp
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: !_isSignUp
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.06),
                                                  blurRadius: 4,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Sign In',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: !_isSignUp
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: !_isSignUp
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = true;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isSignUp
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _isSignUp
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.06),
                                                  blurRadius: 4,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Create Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: _isSignUp
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: _isSignUp
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Error Banner
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFFCA5A5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: Color(0xFFDC2626), size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFB91C1C),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final appState = context.read<AppState>();
                                      appState.loginAsDemoUser(
                                        name: _nameController.text.trim().isNotEmpty
                                            ? _nameController.text.trim()
                                            : 'Naman Sethi',
                                        role: _selectedRole,
                                        email: _emailController.text.trim().isNotEmpty
                                            ? _emailController.text.trim()
                                            : 'naman.sethi@example.com',
                                      );
                                    },
                                    icon: const Icon(Icons.bolt_rounded, size: 16),
                                    label: const Text('Bypass & Enter Demo Mode ➔'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                      minimumSize:
                                          const Size(double.infinity, 32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Sign Up Full Name Field
                          if (_isSignUp) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'e.g. Naman Sethi',
                                prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Role Selector Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Workspace Role',
                                prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              isExpanded: true,
                              items: _availableRoles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedRole = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Confirm Password Field (Sign Up only)
                          if (_isSignUp) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(
                                    Icons.lock_reset_rounded,
                                    size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 22),

                          // Submit Action Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isSignUp
                                        ? 'Create Workspace Account'
                                        : 'Sign In to Workspace',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          // Instant Demo Access Button
                          OutlinedButton.icon(
                            onPressed: () {
                              final appState = context.read<AppState>();
                              appState.loginAsDemoUser(
                                name: _nameController.text.trim().isNotEmpty
                                    ? _nameController.text.trim()
                                    : 'Naman Sethi',
                                role: _selectedRole,
                                email: _emailController.text.trim().isNotEmpty
                                    ? _emailController.text.trim()
                                    : 'naman.sethi@example.com',
                              );
                            },
                            icon: const Icon(Icons.bolt_rounded,
                                color: Color(0xFF0EA5E9), size: 18),
                            label: const Text(
                              '⚡ Instant Demo Access (Skip Login)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              side:
                                  const BorderSide(color: Color(0xFF0EA5E9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Demo quick fill row for presentation
                          const Divider(height: 24),
                          const Text(
                            'Quick Demo / Viva Credentials (Click to Enter)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Naman (Lead)',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.person, size: 14),
                                onPressed: () {
                                  _quickFillDemo(
                                    'naman.sethi@example.com',
                                    'Project Lead & Senior Engineer',
                                    'Naman Sethi',
                                  );
                                  final appState = context.read<AppState>();
                                  appState.loginAsDemoUser(
                                    name: 'Naman Sethi',
                                    role: 'Project Lead & Senior Engineer',
                                    email: 'naman.sethi@example.com',
                                  );
                                },
                              ),
                              ActionChip(
                                label: const Text('Soham (Tech Lead)',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.person, size: 14),
                                onPressed: () {
                                  _quickFillDemo(
                                    'soham.karandikar@example.com',
                                    'Tech Lead & Architect',
                                    'Soham Karandikar',
                                  );
                                  final appState = context.read<AppState>();
                                  appState.loginAsDemoUser(
                                    name: 'Soham Karandikar',
                                    role: 'Tech Lead & Architect',
                                    email: 'soham.karandikar@example.com',
                                  );
                                },
                              ),
                              ActionChip(
                                label: const Text('Aavani (Backend)',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.person, size: 14),
                                onPressed: () {
                                  _quickFillDemo(
                                    'aavani.perumbessi@example.com',
                                    'Backend & Cloud Specialist',
                                    'Aavani Perumbessi',
                                  );
                                  final appState = context.read<AppState>();
                                  appState.loginAsDemoUser(
                                    name: 'Aavani Perumbessi',
                                    role: 'Backend & Cloud Specialist',
                                    email: 'aavani.perumbessi@example.com',
                                  );
                                },
                              ),
                              ActionChip(
                                label: const Text('Naaz (Designer)',
                                    style: TextStyle(fontSize: 11)),
                                avatar: const Icon(Icons.person, size: 14),
                                onPressed: () {
                                  _quickFillDemo(
                                    'naaz.ahmedi@example.com',
                                    'Product Designer (UI/UX)',
                                    'Naaz Ahmedi',
                                  );
                                  final appState = context.read<AppState>();
                                  appState.loginAsDemoUser(
                                    name: 'Naaz Ahmedi',
                                    role: 'Product Designer (UI/UX)',
                                    email: 'naaz.ahmedi@example.com',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
