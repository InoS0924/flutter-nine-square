// dart
import '../data/user_state.dart';
import './login.dart';
import './mandal_list.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// app

// some package

class LoginCheck extends StatefulWidget {
  @override
  _LoginCheckState createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  @override
  void initState() {
    super.initState();
    Future(() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userState = Provider.of<UserState>(context, listen: false);
      if (currentUser == null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return LoginPage();
          }),
        );
      } else {
        userState.setUser(currentUser);
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return MandalListPage();
          }),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}
