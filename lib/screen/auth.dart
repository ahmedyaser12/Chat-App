import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widget/add_image.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  File? getImage;
  var isLogin = true;
  var enteredEmail = '';
  var username = '';
  var enteredPassword = '';
  var isAuthenticating = false;

  Future<void> onSubmit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !isLogin && getImage == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('User_image')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(getImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': username,
          'email': enteredEmail,
          'password': enteredPassword,
          'imgUrl': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed '),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 50,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/image/img.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          !isLogin
                              ? InputImage(
                                  tackImage: (selectedImage) {
                                    getImage = selectedImage;
                                  },
                                )
                              : const Center(),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Email Address'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please entre a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (!isLogin)
                            TextFormField(
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                  label: Text('Username')),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please entre a valid Username';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                username = value!;
                              },
                            ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text('Password')),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(isLogin ? 'Login' : 'Signup'),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
