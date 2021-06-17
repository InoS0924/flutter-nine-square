// dart
import 'package:nine_square/data/const_list.dart';

import './data/user_state.dart';
import './pages/login_check.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// app

// some package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserState userState = UserState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
        title: '9-Square',
        theme: ThemeData(
          primarySwatch: user_color,
        ),
        home: LoginCheck(),
      ),
    );
  }
}
