// dart
import '../data/user_state.dart';
import '../data/const_list.dart';
import './nine_square.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class EditNineSquarePage extends StatefulWidget {
  var pDoc, childDocs;
  EditNineSquarePage(this.pDoc, this.childDocs);

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
    for (var document in widget.childDocs) {
      String docId = document.id;
      var tecontroller = TextEditingController(text: document['title']);
      if (document['order'] == 5) {
        docId = widget.pDoc.id;
        tecontroller = TextEditingController(text: widget.pDoc['title']);
      }
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
          for (var document in widget.childDocs)
            (document['order'] == 5)
                ? Container(
                    margin: _padding,
                    padding: _padding,
                    alignment: Alignment.center,
                    child: TextFormField(
                      autofocus: true,
                      controller: _controllerTitleMap[widget.pDoc.id],
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration.collapsed(
                        hintText: 'some title',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          editTitleMap[widget.pDoc.id] = value;
                        });
                      },
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
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
          final depthNow = userState.depth;
          final rootId = userState.topicList[0];
          final basePath =
              '$users_collection_name/${user.email}/$root_collection_name';
          String pDocPath = '';
          String cDocPath = '';
          if (depthNow == 1) {
            pDocPath = basePath;
            cDocPath = "$basePath/$rootId/$trunk_collection_name/";
          } else if (depthNow == 2) {
            pDocPath = "$basePath/$rootId/$trunk_collection_name/";
            cDocPath = pDocPath;
          }
          final date = DateTime.now().toLocal().toIso8601String();

          // update editted parent docs
          var pDoc = widget.pDoc;
          String? pDocTitle = editTitleMap[pDoc.id];
          if (pDocTitle != null && pDoc['title'] != pDocTitle) {
            var pDocRef =
                FirebaseFirestore.instance.collection(pDocPath).doc(pDoc.id);
            await pDocRef.update(
              {
                'change_date': date,
                'title': pDocTitle,
              },
            );
            // get updated parent
            pDoc = await pDocRef.get();
          }

          // update editted child docs
          for (var document in widget.childDocs) {
            String? editTitle = editTitleMap[document.id];
            if (editTitle != null && document['title'] != editTitle) {
              await FirebaseFirestore.instance
                  .collection(cDocPath)
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
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) {
              return NineSquarePage(
                pDocPath,
                pDoc.id,
                pDoc['title'],
                depthNow,
              );
            }),
          );
        },
      ),
    );
  }
}
