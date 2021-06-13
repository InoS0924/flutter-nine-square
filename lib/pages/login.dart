// dart
import '../data/user_state.dart';
import './mandal_list.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// app

// some package

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String infoText = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Register'),
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      userState.setUser(result.user!);
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return MandalListPage();
                        }),
                      );
                    } catch (e) {
                      setState(() {
                        infoText = "Registration failure: ${e.toString()}";
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  child: Text('Login'),
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      userState.setUser(result.user!);
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return MandalListPage();
                        }),
                      );
                    } catch (e) {
                      setState(() {
                        infoText = "Login failure: ${e.toString()}";
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
