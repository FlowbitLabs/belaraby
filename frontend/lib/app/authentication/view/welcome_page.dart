import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenHeight / 3,
            width: screenWidth,
            decoration: const BoxDecoration(
              color: Color.fromARGB(0, 202, 3, 3),
              borderRadius: BorderRadius.all(Radius.circular(70))
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belaraby' , 
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20,),
              const Icon(Icons.book , color: Colors.red, size: 70,),
              const SizedBox(height: 20,),
              const Text(
                'Welcome to Belaraby' , 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              const Text(
                'Thank you for choosing us in your journey to start learning arabic.Through an easy and innovative way you will become fluent in no time', 
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ), 
                child: const Text('Sign up')
                ),
                Row(
                  children: [
                    const Text(
                      'Already have an account ?',
                      style: TextStyle(
                        fontSize: 5
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, 
                      child: const Text(
                        'Login in',
                        style: TextStyle(
                          color: Colors.blue
                        ),
                        )
                      )
                  ],
                )
            ],
          ),
          )
        ],
      )
    );
  }
}