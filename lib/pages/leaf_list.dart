// dart
import 'package:nine_square/pages/add_square.dart';

import '../data/user_state.dart';
import '../data/const_list.dart';
import './add_square.dart';
import './edit_square.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class LeafListPage extends StatefulWidget {
  String parentDocPath;
  String parentDocId;
  var parentDoc;
  LeafListPage(this.parentDocPath, this.parentDocId, this.parentDoc);

  @override
  _LeafListPageState createState() => _LeafListPageState();
}

class _LeafListPageState extends State<LeafListPage> {
  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final int depthNow = userState.depth;
    final String rootId = userState.topicList[0];
    final String trunkId = userState.topicList[depthNow - 1];
    final String leafDocPath =
        '$users_collection_name/${user.email}/$root_collection_name/$rootId/$trunk_collection_name/$trunkId/$leaf_collection_name';
    userState.printFeatures("LeafListPage");

    return Scaffold(
      appBar: AppBar(
        title: Text("Action List for ${widget.parentDoc['title']}"),
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
                  .where('parent', isEqualTo: trunkId)
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
                                final date =
                                    DateTime.now().toLocal().toIso8601String();
                                FirebaseFirestore.instance
                                    .collection(leafDocPath)
                                    .doc(document.id)
                                    .update(
                                  {
                                    'change_date': date,
                                    'done': true,
                                  },
                                );
                              }
                              if (result == 'Undone') {
                                final date =
                                    DateTime.now().toLocal().toIso8601String();
                                FirebaseFirestore.instance
                                    .collection(leafDocPath)
                                    .doc(document.id)
                                    .update(
                                  {
                                    'change_date': date,
                                    'done': false,
                                  },
                                );
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
}
