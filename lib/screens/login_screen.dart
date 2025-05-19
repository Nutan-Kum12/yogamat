// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       await Provider.of<AuthService>(context, listen: false)
//           .signInWithEmailAndPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Logo and title
//                 Column(
//                   children: [
//                     Icon(
//                       Icons.self_improvement,
//                       size: 80,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Smart Yoga Mat',
//                       style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Sign in to continue',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 48),

//                 // Login form
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Email field
//                       TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.email),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                               .hasMatch(value)) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Password field
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Password',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.lock),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 8),

//                       // Forgot password
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             // TODO: Implement forgot password
//                           },
//                           child: const Text('Forgot Password?'),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Error message
//                       if (_errorMessage != null)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 16.0),
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontSize: 14,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),

//                       // Login button
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _login,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               )
//                             : const Text(
//                                 'SIGN IN',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Register link
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Don't have an account?"),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const RegisterScreen(),
//                                 ),
//                               );
//                             },
//                             child: const Text('Sign Up'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
