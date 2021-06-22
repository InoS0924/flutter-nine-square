// dart
import '../data/user_state.dart';
import '../data/const_list.dart';
import './leaf_list.dart';
import './edit_nine_square.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// app

// some package

class NineSquarePage extends StatefulWidget {
  var targetDoc, documents;
  String pDocPath, pDocId, pTitle;
  int depthNow;
  NineSquarePage(this.pDocPath, this.pDocId, this.pTitle, this.depthNow);

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
    // parent doc
    widget.targetDoc = await FirebaseFirestore.instance
        .collection(widget.pDocPath)
        .doc(widget.pDocId)
        .get();

    // child docs
    String childDocPath = widget.pDocPath;
    if (widget.depthNow == 1) {
      childDocPath += "/${widget.pDocId}/$trunk_collection_name";
    }
    var editTargetDocSnapshots = await FirebaseFirestore.instance
        .collection(childDocPath)
        .where('parent', isEqualTo: widget.pDocId)
        .orderBy('order')
        .get();
    widget.documents = editTargetDocSnapshots.docs;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;
    final String rootId = userState.topicList[0];
    final String basePath =
        "$users_collection_name/${user.email}/$root_collection_name";
    final String trunkDocPath = '$basePath/$rootId/$trunk_collection_name/';
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
                for (var document in widget.documents)
                  (document['order'] == 5)
                      ? OutlinedButton(
                          onPressed: () async {
                            userState.upStair();
                            userState.popTopic();
                            Navigator.of(context).pop();
                          },
                          child: Text(widget.targetDoc['title']),
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
                                      trunkDocPath,
                                      document.id,
                                      document['title'],
                                      userState.depth,
                                    );
                                  }),
                                );
                              } else {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return LeafListPage(
                                        trunkDocPath, document.id, document);
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
              return EditNineSquarePage(widget.targetDoc, widget.documents);
            }),
          );
        },
      ),
    );
  }
}
