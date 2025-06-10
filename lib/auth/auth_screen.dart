// // ignore_for_file: curly_braces_in_flow_control_structures

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   bool isLogin = true;
//   final _formKey = GlobalKey<FormState>();
//   final _auth = FirebaseAuth.instance;

//   String email = '';
//   String password = '';
//   String confirmPassword = '';
//   String name = '';
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;

//   void _toggleForm() {
//     setState(() {
//       isLogin = !isLogin;
//       _formKey.currentState?.reset();
//       email = password = confirmPassword = name = '';
//     });
//   }

//   void _togglePasswordVisibility() =>
//       setState(() => _obscurePassword = !_obscurePassword);
//   void _toggleConfirmVisibility() =>
//       setState(() => _obscureConfirm = !_obscureConfirm);

//   Future<void> _submit() async {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     if (!isValid) return;

//     _formKey.currentState?.save();
//     setState(() => _isLoading = true);

//     try {
//       if (isLogin) {
//         await _auth.signInWithEmailAndPassword(
//           email: email.trim(),
//           password: password.trim(),
//         );
//       } else {
//         if (password != confirmPassword) {
//           _showError('Passwords do not match');
//           setState(() => _isLoading = false);
//           return;
//         }
//         await _auth.createUserWithEmailAndPassword(
//           email: email.trim(),
//           password: password.trim(),
//         );

//         final user = _auth.currentUser;
//         if (user != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .set({
//                 'email': email.trim(),
//                 'name': name.trim(),
//                 'createdAt': FieldValue.serverTimestamp(),
//               });
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Authentication error');
//     } catch (_) {
//       _showError('An unexpected error occurred');
//     }

//     setState(() => _isLoading = false);
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Theme.of(context).colorScheme.error,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required bool obscure,
//     required Function(String?) onSaved,
//     required String? Function(String?) validator,
//     Widget? suffixIcon,
//     String? helperText,
//   }) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return TextFormField(
//       key: ValueKey(label),
//       obscureText: obscure,
//       decoration: InputDecoration(
//         labelText: label,
//         helperText: helperText,
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: const Color(0xFFE0E0E0),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: colorScheme.primary, width: 2),
//         ),
//       ),
//       validator: validator,
//       onSaved: onSaved,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 400),
//             child: Container(
//               key: ValueKey(isLogin),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: colorScheme.surface,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 16,
//                     offset: Offset(0, 8),
//                   ),
//                 ],
//               ),
//               width: 360,
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       isLogin ? 'Sign In' : 'Sign Up',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                      if (!isLogin) ...[
//                     _buildTextField(
//                       label: 'Name',
//                       obscure: false,
//                       onSaved: (val) => name = val ?? '',
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty)
//                           return 'Enter your name';
//                         return null;
//                       },
//                     ),],
//                     const SizedBox(height: 10),
//                     _buildTextField(
//                       label: 'Email',
//                       obscure: false,
//                       onSaved: (val) => email = val ?? '',
//                       validator: (val) {
//                         if (val == null || !val.contains('@'))
//                           return 'Enter a valid email';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       label: 'Password',
//                       obscure: _obscurePassword,
//                       onSaved: (val) => password = val ?? '',
//                       validator: (val) {
//                         if (val == null || val.length < 6)
//                           return 'Password must be 6+ chars';
//                         return null;
//                       },
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: colorScheme.primary,
//                         ),
//                         onPressed: _togglePasswordVisibility,
//                       ),
//                     ),
//                     if (!isLogin) ...[
//                       const SizedBox(height: 16),
//                       _buildTextField(
//                         label: 'Confirm Password',
//                         obscure: _obscureConfirm,
//                         onSaved: (val) => confirmPassword = val ?? '',
//                         validator: (val) {
//                           if (val == null || val.length < 6)
//                             return 'Confirm your password';
//                           return null;
//                         },
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureConfirm
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: colorScheme.primary,
//                           ),
//                           onPressed: _toggleConfirmVisibility,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 24),
//                     _isLoading
//                         ? CircularProgressIndicator(color: colorScheme.primary)
//                         : SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: colorScheme.primary,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                               ),
//                               onPressed: _submit,
//                               child: Text(
//                                 isLogin ? 'Login' : 'Create Account',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                     const SizedBox(height: 12),
//                     TextButton(
//                       onPressed: _toggleForm,
//                       child: Text(
//                         isLogin
//                             ? 'Don\'t have an account? Sign Up'
//                             : 'Already have an account? Sign In',
//                         style: TextStyle(color: colorScheme.secondary),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  String confirmPassword = '';
  String name = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      email = password = confirmPassword = name = '';
    });
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);
  void _toggleConfirmVisibility() =>
      setState(() => _obscureConfirm = !_obscureConfirm);

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } else {
        if (password != confirmPassword) {
          _showError('Passwords do not match');
          setState(() => _isLoading = false);
          return;
        }
        await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        final user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'email': email.trim(),
                'name': name.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication error');
    } catch (_) {
      _showError('An unexpected error occurred');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required bool obscure,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    String? helperText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      key: ValueKey(label),
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:  const Color.fromARGB(255, 250, 247, 247),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(isLogin),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              width: 360,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLogin ? 'Sign In' : 'Sign Up',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isLogin) ...[
                      _buildTextField(
                        label: 'Name',
                        obscure: false,
                        onSaved: (val) => name = val ?? '',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter your name';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Email',
                      obscure: false,
                      onSaved: (val) => email = val ?? '',
                      validator: (val) {
                        if (val == null || !val.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      obscure: _obscurePassword,
                      onSaved: (val) => password = val ?? '',
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Password must be 6+ chars';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorScheme.primary,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    if (!isLogin) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Confirm Password',
                        obscure: _obscureConfirm,
                        onSaved: (val) => confirmPassword = val ?? '',
                        validator: (val) {
                          if (val == null || val.length < 6) {
                            return 'Confirm your password';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.primary,
                          ),
                          onPressed: _toggleConfirmVisibility,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator(color: colorScheme.primary)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(
                                isLogin ? 'Login' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(
                        isLogin
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Sign In',
                        style: TextStyle(color: colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
