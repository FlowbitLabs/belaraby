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
          child: TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText:  'Enter Your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.text,),
        ),
      )
    );
  }
}