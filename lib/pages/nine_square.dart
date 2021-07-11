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

import 'package:nine_square/pages/leaf_list.dart';
import 'package:nine_square/pages/edit_nine_square.dart';

class NineSquarePage extends StatefulWidget {
  var childDocs;
  String pDocPath, pDocId, pTitle;
  NineSquarePage(this.pDocPath, this.pDocId, this.pTitle);

  @override
  _NineSquarePageState createState() => _NineSquarePageState();
}

class _NineSquarePageState extends State<NineSquarePage> {
  Future<bool>? _future;

  @override
  void initState() {
    super.initState();
    _future = getNineSquares();
  }

  Future<bool> getNineSquares() async {
    // get child docs
    var childDocSnapshot = await FirebaseFirestore.instance
        .collection(widget.pDocPath)
        .where('parents', arrayContains: widget.pDocId)
        .limit(num_child_square)
        .orderBy('order')
        .get();
    widget.childDocs = childDocSnapshot.docs;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    userState.printFeatures("NineSquarePage");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            userState.upStair();
            userState.popTopic();
            return Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var document in widget.childDocs)
                  (document.id == widget.pDocId)
                      ? OutlinedButton(
                          onPressed: () async {
                            userState.upStair();
                            userState.popTopic();
                            Navigator.of(context).pop();
                          },
                          child: Text(document['title']),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: user_color.withOpacity(
                                document['done_score'] /
                                    document['max_achievement_score']),
                          ),
                          child: OutlinedButton(
                            child: Text(
                              document['title'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              userState.downStair();
                              userState.pushTopic(document.id);
                              if (userState.depth <= max_depth) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return NineSquarePage(
                                      widget.pDocPath,
                                      document.id,
                                      document['title'],
                                    );
                                  }),
                                );
                              } else {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return LeafListPage(widget.pDocPath,
                                        document.id, document['title']);
                                  }),
                                );
                              }
                            },
                          ),
                        )
              ],
            );
          }
          return Center(
            child: Text('Now loading ...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return EditNineSquarePage(widget.childDocs);
            }),
          );
        },
      ),
    );
  }
}
