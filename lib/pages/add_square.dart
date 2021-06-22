// dart
import '../data/user_state.dart';
import '../data/const_list.dart';
import '../utils/square_creator.dart';
import 'dart:math';

// third party
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class AddSquarePage extends StatefulWidget {
  String docPath;
  String addType;
  AddSquarePage(this.docPath, this.addType);

  @override
  _AddSquarePageState createState() => _AddSquarePageState();
}

class _AddSquarePageState extends State<AddSquarePage> {
  Map<String, dynamic> SquareInfo = {
    'title': '',
    'detail': '',
  };

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final int depthNow = userState.depth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add new one'),
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
                    SquareInfo['title'] = value;
                  });
                },
              ),
              if (widget.addType == 'leaf') const SizedBox(height: 8),
              if (widget.addType == 'leaf')
                DropdownButtonFormField<int>(
                  items: ScoreDropdownMenuItem,
                  decoration: InputDecoration(labelText: 'Score'),
                  value: SquareInfo['score'],
                  onChanged: (value) => {
                    setState(() {
                      SquareInfo['score'] = value;
                    }),
                  },
                ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Detail'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    SquareInfo['detail'] = value;
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
                    SquareInfo['create_date'] = date;
                    SquareInfo['change_date'] = date;
                    if (widget.addType == 'root') {
                      SquareInfo['max_achievement_score'] =
                          base_max_score * pow(num_child_square - 1, max_depth);
                      SquareInfo['done_score'] = 0;
                    }
                    if (widget.addType == 'leaf') {
                      SquareInfo['parent'] = userState.topicList[depthNow - 1];
                      SquareInfo['done'] = false;
                    }
                    await FirebaseFirestore.instance
                        .collection(widget.docPath)
                        .add(SquareInfo)
                        .then((docRef) async {
                      if (widget.addType == 'root') {
                        String docId = docRef.id;
                        print("Document written with ID: $docId");
                        await init_squares(
                          '${widget.docPath}/$docId/$trunk_collection_name',
                          docRef,
                        );
                      }
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
