import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/LoginAuth.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var loading = false;

  closeLoginPage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              constraints: BoxConstraints(maxWidth: 200),
              margin: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), label: Text('Email')),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Email';
                        }
                        return null;
                      },
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Password')),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                        )),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(minimumSize: Size(100, 45)),
                      onPressed: loading
                          ? null
                          : () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                try {
                                  var login = await LoginAuth.login(
                                      emailController.text,
                                      passwordController.text);
                                  closeLoginPage();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Incorrect Login"),
                                    ),
                                  );
                                }
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                      child: Text(loading ? 'Loading...' : 'Log In'),
                    ),
                  ],
                ),
              ))
        ]),
      ),
    );
  }
}
