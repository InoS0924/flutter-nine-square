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

import 'package:nine_square/pages/login.dart';
import 'package:nine_square/pages/nine_square.dart';
import 'package:nine_square/pages/add_square.dart';
import 'package:nine_square/pages/edit_square.dart';

class MandalListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final String docPath =
        '$users_collection_name/${user.email}/$square_collection_name';
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
                  .collection(docPath)
                  .where('order', isEqualTo: root_sqaure_order)
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
                                    docPath,
                                    document.id,
                                    document['title'],
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
                                    return EditSquarePage(
                                        docPath, document.id, 'root', document);
                                  }),
                                );
                              }
                              if (result == 'Delete') {
                                FirebaseFirestore.instance
                                    .collection(docPath)
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
              return AddSquarePage(docPath, 'root');
            }),
          );
        },
      ),
    );
  }
}
