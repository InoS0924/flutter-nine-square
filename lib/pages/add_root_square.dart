// dart
import '../data/user_state.dart';
import '../data/const_list.dart';
import '../utils/square_creator.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class AddRootSquarePage extends StatefulWidget {
  AddRootSquarePage();

  @override
  _AddRootSquarePageState createState() => _AddRootSquarePageState();
}

class _AddRootSquarePageState extends State<AddRootSquarePage> {
  String titleText = '';
  String detailText = '';

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final String rootDocPath =
        '$users_collection_name/${user.email}/$root_collection_name';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Mandal'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (String value) {
                  setState(() {
                    titleText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Detail'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    detailText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    final date = DateTime.now().toLocal().toIso8601String();
                    await FirebaseFirestore.instance
                        .collection(rootDocPath)
                        .add(
                      {
                        'title': titleText,
                        'detail': detailText,
                        'create_date': date,
                        'change_date': date,
                      },
                    ).then((docRef) async {
                      String docId = docRef.id;
                      String docPath =
                          '$rootDocPath/$docId/$trunk_collection_name';
                      print("Document written with ID: $docId");
                      await init_trunk_squares(docPath, docRef);
                    });
                    return Navigator.of(context).pop();
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
