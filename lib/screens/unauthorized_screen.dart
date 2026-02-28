import 'package:flutter/material.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  void _goHome(BuildContext context) {
    // Replace with the most appropriate route in your app
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        automaticallyImplyLeading: true, // show back button if available
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'You do not have permission to view this page.\n'
                'If you believe this is an error, please contact your administrator or log in with a different account.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Return to Home'),
                onPressed: () => _goHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
