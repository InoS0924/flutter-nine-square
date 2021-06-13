// dart
import '../data/user_state.dart';
import '../data/const_list.dart';
import './leaf_list.dart';
import './edit_square.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class NineSquarePage extends StatefulWidget {
  var targetDoc;
  NineSquarePage(this.targetDoc);

  @override
  _NineSquarePageState createState() => _NineSquarePageState();
}

class _NineSquarePageState extends State<NineSquarePage> {
  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final int depthNow = userState.depth;
    final String rootId = userState.topicList[0];
    final String parentId = userState.topicList[depthNow - 1];
    final String trunkDocPath =
        '$users_collection_name/${user.email}/$root_collection_name/$rootId/$trunk_collection_name/';
    userState.printFeatures("NineSquarePage");

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.targetDoc['title']}"),
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
                  .collection(trunkDocPath)
                  .where('parent', isEqualTo: parentId)
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return GridView.count(
                    crossAxisCount: 3,
                    children: documents.map((document) {
                      if (document['order'] == 5) {
                        return OutlinedButton(
                          onPressed: () async {
                            userState.upStair();
                            userState.popTopic();
                            Navigator.of(context).pop();
                          },
                          child: Text(widget.targetDoc['title']),
                        );
                      } else {
                        String editType = 'trunk';
                        return (document['create_date'] ==
                                document['change_date'])
                            ? IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  if (depthNow != max_depth) {
                                    editType = 'trunk_first';
                                  }
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return EditSquarePage(trunkDocPath,
                                          document.id, editType, document);
                                    }),
                                  );
                                },
                              )
                            : PopupMenuButton(
                                onSelected: (String result) async {
                                  // Detail
                                  if (result == 'Detail') {
                                    userState.downStair();
                                    userState.pushTopic(
                                        document.id, document['title']);
                                    if (userState.depth <= max_depth) {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return NineSquarePage(document);
                                        }),
                                      );
                                    } else {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return LeafListPage(trunkDocPath,
                                              document.id, document);
                                        }),
                                      );
                                    }
                                  }
                                  // Edit
                                  if (result == 'Edit') {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        return EditSquarePage(trunkDocPath,
                                            document.id, editType, document);
                                      }),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuItem<String>>[
                                  DetailPopupMenuItem,
                                  EditPopupMenuItem
                                ],
                                child: Container(
                                  child: Text(document['title']),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              );
                      }
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
    );
  }
}
