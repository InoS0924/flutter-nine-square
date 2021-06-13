// dart
import '../data/user_state.dart';
import '../data/const_list.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class AddLeafSquarePage extends StatefulWidget {
  AddLeafSquarePage();

  @override
  _AddLeafSquarePageState createState() => _AddLeafSquarePageState();
}

class _AddLeafSquarePageState extends State<AddLeafSquarePage> {
  String titleText = '';
  double score = 0;
  String detailText = '';

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final int depthNow = userState.depth;
    final String rootId = userState.topicList[0];
    final String trunkId = userState.topicList[depthNow - 1];
    final String leafDocPath =
        '$users_collection_name/${user.email}/$root_collection_name/$rootId/$trunk_collection_name/$trunkId/$leaf_collection_name';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add new action'),
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
                decoration: InputDecoration(labelText: 'Score'),
                onChanged: (String value) {
                  setState(() {
                    score = double.parse(value);
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
                        .collection(leafDocPath)
                        .add(
                      {
                        'title': titleText,
                        'score': score,
                        'parent': trunkId,
                        'detail': detailText,
                        'create_date': date,
                        'change_date': date,
                        'done': false
                      },
                    );
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
