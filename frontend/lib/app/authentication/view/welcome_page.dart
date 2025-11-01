import 'package:belaraby/app/authentication/view/login_page.dart';
import 'package:belaraby/app/authentication/view/signup_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  
  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenHeight / 2,
            width: screenWidth /2 ,
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
              const SizedBox(height: 10,),
              const Text(
                '''
                Thank you for choosing us in your journey to start learning arabic.
                Through an easy and innovative way you will become fluent in no time.
                ''', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=> const SignupPage())
                  );
                },
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
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text(
                      'Already have an account ?',
                      style: TextStyle(
                        fontSize: 5
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context)=> const LoginPage())
                        );
                      }, 
                      child: const Text(
                        'Log in',
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