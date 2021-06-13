// dart
import '../data/const_list.dart';
import 'dart:math';

// third party
import 'package:cloud_firestore/cloud_firestore.dart';

// app

// some package

// Todo: Change batch process!!!
Future<List> create_init_child_squares(docPath, parentDocRef, depth) async {
  final parentDocId = parentDocRef.id;
  final date = DateTime.now().toLocal().toIso8601String();
  Map<String, dynamic> trunkSquare = {};
  num maxAchieveScore =
      base_max_score * pow(num_child_square - 1, max_depth - depth);

  List createdList = [];
  for (int i = 1; i <= num_child_square; i++) {
    trunkSquare = {
      'title': 'edit here',
      'detail': '',
      'create_date': date,
      'change_date': date,
      'parent': parentDocId,
      'max_achievement_score': maxAchieveScore,
      'done_score': 0,
      'order': i,
    };
    await FirebaseFirestore.instance
        .collection(docPath)
        .add(trunkSquare)
        .then((docRef) {
      createdList.add(docRef);
    });
  }
  return createdList;
}

Future<void> init_trunk_squares(docPath, parentDocRef) async {
  // Depth1
  List trunkSquareListDepth1 =
      await create_init_child_squares(docPath, parentDocRef, 1);
  // Depth2
  for (var pDocRef in trunkSquareListDepth1) {
    await create_init_child_squares(docPath, pDocRef, 2);
  }
}
