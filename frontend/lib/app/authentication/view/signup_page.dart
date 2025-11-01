import 'package:belaraby/app/authentication/cubit/auth_cubit.dart';
import 'package:belaraby/app/authentication/cubit/auth_state.dart';
import 'package:belaraby/app/authentication/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(220, 8, 173, 228),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('USER CREATED'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Navigate to LoginPage after success
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 15,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Email and Password cannot be empty'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                context
                                    .read<AuthCubit>()
                                    .signup(email, password);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 233, 235, 236),
                          foregroundColor:
                              const Color.fromARGB(255, 72, 4, 230),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('SIGN UP'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
