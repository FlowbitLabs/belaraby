import 'package:flutter/material.dart';


// part of 'welcome_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(220, 8, 173, 228),
      body: SafeArea(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              obscureText: true, //hide the characters
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                prefixIcon: const Icon(Icons.password),
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
          ],
        ),
      ),
    ),
      );
  }
}