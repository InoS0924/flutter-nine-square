// dart
import 'package:nine_square/pages/add_square.dart';

import '../data/user_state.dart';
import '../data/const_list.dart';
import './login.dart';
import './nine_square.dart';
import './add_square.dart';
import './edit_square.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class MandalListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final depthNow = userState.depth;
    final String rootDocPath =
        '$users_collection_name/${user.email}/$root_collection_name';
    userState.printFeatures("MandalListPage");

    return Scaffold(
      appBar: AppBar(
        title: Text('9-square List: ${user.email}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(rootDocPath)
                  .orderBy('change_date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          title: TextButton(
                            child: Text(document['title']),
                            onPressed: () async {
                              userState.downStair();
                              userState.pushTopic(document.id);
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return NineSquarePage(
                                    rootDocPath,
                                    document.id,
                                    document['title'],
                                    userState.depth,
                                  );
                                }),
                              );
                            },
                          ),
                          subtitle:
                              Text("Last modified: ${document['change_date']}"),
                          trailing: PopupMenuButton(
                            onSelected: (String result) async {
                              if (result == 'Edit') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return EditSquarePage(rootDocPath,
                                        document.id, 'root', document);
                                  }),
                                );
                              }
                              if (result == 'Delete') {
                                FirebaseFirestore.instance
                                    .collection(rootDocPath)
                                    .doc(document.id)
                                    .delete();
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuItem<String>>[
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
              return AddSquarePage(rootDocPath, 'root');
            }),
          );
        },
      ),
    );
  }
}
