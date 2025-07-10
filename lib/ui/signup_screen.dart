
import 'package:flutter/material.dart';
import 'package:orion/services/firestore_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Scaffold, AppBar, TextField, CircularProgressIndicator;
import 'package:orion/ui/chat_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      // In a real app, show a proper error message
      print("Please fill all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Using email as a temporary user ID until auth is implemented
      await _firestoreService.addUser(
        userId: _emailController.text,
        name: _nameController.text,
        email: _emailController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }
    } catch (e) {
      print("Error during sign up: $e");
      // In a real app, show a user-facing error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                PrimaryButton(
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
