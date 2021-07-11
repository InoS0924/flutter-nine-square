// dart
import 'dart:math';

// third party
import 'package:cloud_firestore/cloud_firestore.dart';

// app

// some package
import 'package:nine_square/data/const_list.dart';

Future<void> init_squares(docPath, parentDocRef) async {
  List<Future<bool>> result = [];
  for (int i = 1; i <= num_child_square; i++) {
    if (i != 5) {
      result.add(create_init_child_squares(docPath, parentDocRef, i));
    }
  }
  await Future.wait(result);
}

// Todo: Change batch process!!!
Future<bool> create_init_child_squares(docPath, parentDocRef, index) async {
  final date = DateTime.now().toLocal().toIso8601String();
  var childDocRef = FirebaseFirestore.instance.collection(docPath).doc();
  String childDocId = childDocRef.id;

  Map<String, dynamic> trunkSquare = {
    'title': '',
    'create_date': date,
    'change_date': date,
    'parents': [parentDocRef.id, childDocId],
    'max_achievement_score':
        base_max_score * pow(num_child_square - 1, max_depth - 1),
    'done_score': 0,
    'order': index * 10 + 5,
  };
  // depth 1
  await childDocRef.set(trunkSquare);
  // depth 2
  for (int i = 1; i <= num_child_square; i++) {
    if (i != 5) {
      var gChildDocRef = FirebaseFirestore.instance.collection(docPath).doc();
      String gChildDocId = gChildDocRef.id;
      trunkSquare['parents'] = [childDocId, gChildDocId];
      trunkSquare['max_achievement_score'] =
          base_max_score * pow(num_child_square - 1, max_depth - 2);
      trunkSquare['order'] = index * 10 + i;
      gChildDocRef.set(trunkSquare);
    }
  }
  return true;
}
