// dart
import '../utils/square_creator.dart';

// third party
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// app

// some package

class EditSquarePage extends StatefulWidget {
  String docPath;
  String editDocId;
  String editType;
  var targetDoc;
  EditSquarePage(this.docPath, this.editDocId, this.editType, this.targetDoc);

  @override
  _EditSquarePageState createState() => _EditSquarePageState();
}

class _EditSquarePageState extends State<EditSquarePage> {
  Map<String, dynamic> SquareInfo = {};
  TextEditingController? _controllerTitle,
      _controllerDetail,
      _controllerAchieve;

  List<DropdownMenuItem<int>> _items = [
    for (int i = 1; i <= 10; i++)
      DropdownMenuItem(
        child: Text('$i'),
        value: i,
      )
  ];

  void initState() {
    super.initState();
    // common
    _controllerTitle = TextEditingController(text: widget.targetDoc['title']);
    _controllerDetail = TextEditingController(text: widget.targetDoc['detail']);
    // for trunk_first
    // for trunk
    // for leaf
    if (widget.editType == 'leaf') {
      SquareInfo['score'] = widget.targetDoc['score'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _controllerTitle,
                onChanged: (String value) {
                  setState(() {
                    SquareInfo['title'] = value;
                  });
                },
              ),
              if (widget.editType == 'leaf') const SizedBox(height: 8),
              if (widget.editType == 'leaf')
                DropdownButtonFormField<int>(
                  items: _items,
                  decoration: InputDecoration(labelText: 'Score'),
                  hint: Text('Choose score 1 to 10'),
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
                controller: _controllerDetail,
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
                  child: Text('Update'),
                  onPressed: () async {
                    final date = DateTime.now().toLocal().toIso8601String();
                    SquareInfo['change_date'] = date;
                    final docRef = FirebaseFirestore.instance
                        .collection(widget.docPath)
                        .doc(widget.editDocId);
                    await docRef.update(SquareInfo);
                    if (widget.editType == 'trunk_first') {
                      await create_init_child_squares(
                        widget.docPath,
                        docRef,
                        2,
                      );
                    }
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
