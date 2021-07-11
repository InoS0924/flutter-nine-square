// dart

// third party
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package
import 'package:nine_square/data/user_state.dart';
import 'package:nine_square/data/const_list.dart';

import 'package:nine_square/pages/add_square.dart';
import 'package:nine_square/pages/edit_square.dart';

class LeafListPage extends StatefulWidget {
  String pDocPath, pDocId, pTitle;
  LeafListPage(this.pDocPath, this.pDocId, this.pTitle);

  @override
  _LeafListPageState createState() => _LeafListPageState();
}

class _LeafListPageState extends State<LeafListPage> {
  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final topicList = userState.topicList;
    final baseDocPath = widget.pDocPath;
    final leafDocPath = '$baseDocPath/${widget.pDocId}/$leaf_collection_name';
    userState.printFeatures("LeafListPage");

    return Scaffold(
      appBar: AppBar(
        title: Text("Action List for ${widget.pTitle}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            userState.upStair();
            userState.popTopic();
            return Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(leafDocPath)
                  .where('parents', arrayContains: widget.pDocId)
                  .orderBy('change_date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          leading: document['done'] ? Icon(Icons.done) : null,
                          selected: document['done'],
                          title: Text(document['title']),
                          subtitle:
                              Text("Last modified: ${document['change_date']}"),
                          trailing: PopupMenuButton(
                            onSelected: (String result) async {
                              if (result == 'Done') {
                                changeDoneState(document, baseDocPath,
                                    leafDocPath, topicList, 'done');
                              }
                              if (result == 'Undone') {
                                changeDoneState(document, baseDocPath,
                                    leafDocPath, topicList, 'undone');
                              }
                              if (result == 'Edit') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return EditSquarePage(leafDocPath,
                                        document.id, 'leaf', document);
                                  }),
                                );
                              }
                              if (result == 'Delete') {
                                FirebaseFirestore.instance
                                    .collection(leafDocPath)
                                    .doc(document.id)
                                    .delete();
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuItem<String>>[
                              if (!document['done']) DonePopupMenuItem,
                              if (document['done']) UndonePopupMenuItem,
                              EditPopupMenuItem,
                              DeletePopupMenuItem,
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return Center(
                  child: Text('Now loading ...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddSquarePage(leafDocPath, 'leaf');
            }),
          );
        },
      ),
    );
  }

  Future<void> changeDoneState(document, String baseDocPath, String leafDocPath,
      List topicList, String mode) async {
    final coef = (mode == 'done' ? 1 : -1);

    final date = DateTime.now().toLocal().toIso8601String();
    final fbInstance = FirebaseFirestore.instance;
    // update leaf
    fbInstance.collection(leafDocPath).doc(document.id).update(
      {
        'change_date': date,
        'done': (mode == 'done' ? true : false),
      },
    );
    // update depth2
    final docRef2 = fbInstance.collection(baseDocPath).doc(topicList[2]);
    final doc2 = await docRef2.get();
    int addedScore = doc2['done_score'] + coef * document['score'];
    docRef2.update(
      {'change_date': date, 'done_score': addedScore},
    );
    // update depth1
    final docRef1 = fbInstance.collection(baseDocPath).doc(topicList[1]);
    final doc1 = await docRef1.get();
    addedScore = doc1['done_score'] + coef * document['score'];
    docRef1.update(
      {'change_date': date, 'done_score': addedScore},
    );
    // update root
    final docRef0 = fbInstance.collection(baseDocPath).doc(topicList[0]);
    final doc0 = await docRef0.get();
    addedScore = doc0['done_score'] + coef * document['score'];
    docRef0.update(
      {'change_date': date, 'done_score': addedScore},
    );
  }
}
