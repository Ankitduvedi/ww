import 'dart:developer';
import 'package:com.while.while_app/feature/auth/controller/auth_controller.dart';
import 'package:com.while.while_app/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:com.while.while_app/utils/routes/routes_name.dart';
import 'package:com.while.while_app/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly'
]);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late GoogleSignInAccount currentUser;
  bool _obscureText = true; // Initially password is obscure

  void handleSignIn(WidgetRef ref) async {
    try {
      ref.read(authControllerProvider.notifier).signInWithGoogle(context);
    } catch (error) {
      log("Sign in error$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Login screen");
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.02;
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? const Loader()
              : Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.05),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/while_transparent.png',
                        width: screenSize.width *
                            0.9, // Dynamic width for the image
                        height: screenSize.height * 0.3,
                      ), // Placeholder for the image
                      SizedBox(height: verticalPadding),

                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Enter Email',
                          labelStyle: GoogleFonts.ptSans(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      SizedBox(height: verticalPadding),
                      TextField(
                        controller: _passwordController,
                        obscureText:
                            _obscureText, // Toggle this boolean to show/hide password
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.ptSans(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          // Added suffixIcon to toggle password visibility
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Change the icon based on the state of _obscureText
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // Update the state to toggle password visibility
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RoutesName.forgot);
                          },
                          child: Text(
                            'Recover Password ?',
                            style: GoogleFonts.ptSans(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),

                      ElevatedButton(
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                                'Please enter email', context);
                          } else if (_passwordController.text.isEmpty) {
                            Utils.flushBarErrorMessage(
                                'Please enter password', context);
                          } else if (_passwordController.text.length < 6) {
                            Utils.flushBarErrorMessage(
                                'Please enter at least 6-digit password',
                                context);
                          } else {
                            ref
                                .read(userProvider.notifier)
                                .update((state) => null);
                            ref
                                .read(authControllerProvider.notifier)
                                .loginWithEmailAndPassword(
                                    _emailController.text.toString(),
                                    _passwordController.text.toString(),
                                    context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          backgroundColor:
                              Colors.white, // Icon color taken from the logo
                          minimumSize:
                              const Size(double.infinity, 50), // Button size
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12), // Inner padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                24), // Rounded corners to match logo style
                            side: BorderSide(
                                color: Colors.blue[
                                    800]!), // Border color taken from the logo
                          ),
                          elevation:
                              0, // No shadow for a flat design similar to the logo
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.ptSans(fontSize: 20),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              ref.read(toggleStateProvider.notifier).state = 2;
                            },
                            style: TextButton.styleFrom(
                              minimumSize: const Size(150, 50),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.ptSans(
                                color:
                                    Colors.blue, // This changes the text color
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: verticalPadding * 1.2),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Divider(
                              thickness:
                                  1, // Set the thickness of the divider as needed
                              color: Colors
                                  .grey, // Set the color of the divider as needed
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'OR',
                              style: GoogleFonts.ptSans(),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness:
                                  1, // Set the thickness of the divider as needed
                              color: Colors
                                  .grey, // Set the color of the divider as needed
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalPadding * 1.4),

                      ElevatedButton(
                        onPressed: () {
                          handleSignIn(ref);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          backgroundColor: Colors.white, // Text and icon color
                          minimumSize:
                              const Size(double.infinity, 50), // Button size
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12), // Inner padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(24), // Rounded corners
                          ),
                          side: BorderSide(
                              color: Colors.grey.shade300), // Border color
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Use MainAxisSize.min to keep the row compact
                          children: <Widget>[
                            Image.asset('assets/google_logo2.png',
                                width: 40, height: 40),
                            const SizedBox(
                                width:
                                    30), // Increase width to increase the distance between the logo and the text
                            Text('Login with Google',
                                style: GoogleFonts.ptSans(fontSize: 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
