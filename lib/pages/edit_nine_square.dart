// dart

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package
import 'package:nine_square/data/user_state.dart';
import 'package:nine_square/data/const_list.dart';

import 'package:nine_square/pages/nine_square.dart';

class EditNineSquarePage extends StatefulWidget {
  var targetDocs;
  EditNineSquarePage(this.targetDocs);

  @override
  _EditNineSquarePageState createState() => _EditNineSquarePageState();
}

class _EditNineSquarePageState extends State<EditNineSquarePage> {
  static const EdgeInsets _padding =
      const EdgeInsets.symmetric(horizontal: 3, vertical: 3);
  Map<String, String> editTitleMap = {};
  Map<String, TextEditingController?> _controllerTitleMap = {};
  void initState() {
    super.initState();
    for (var document in widget.targetDocs) {
      String docId = document.id;
      var tecontroller = TextEditingController(text: document['title']);
      _controllerTitleMap[docId] = tecontroller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    userState.printFeatures("EditNineSquarePage");

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          for (var document in widget.targetDocs)
            Container(
              margin: _padding,
              padding: _padding,
              alignment: Alignment.center,
              child: TextFormField(
                autofocus: true,
                controller: _controllerTitleMap[document.id],
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText: 'some title',
                ),
                onChanged: (String value) {
                  setState(() {
                    editTitleMap[document.id] = value;
                  });
                },
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          final docPath =
              '$users_collection_name/${user.email}/$square_collection_name';
          final date = DateTime.now().toLocal().toIso8601String();
          // update editted docs
          for (var document in widget.targetDocs) {
            String? editTitle = editTitleMap[document.id];
            if (editTitle != null && document['title'] != editTitle) {
              await FirebaseFirestore.instance
                  .collection(docPath)
                  .doc(document.id)
                  .update(
                {
                  'change_date': date,
                  'title': editTitle,
                },
              );
            }
          }
          Navigator.of(context).pop();
          final pDoc = widget.targetDocs[4];
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) {
              return NineSquarePage(
                docPath,
                pDoc.id,
                pDoc['title'],
              );
            }),
          );
        },
      ),
    );
  }
}
