// dart
import '../data/const_list.dart';
import 'dart:math';

// third party
import 'package:cloud_firestore/cloud_firestore.dart';

// app

// some package

Future<void> init_squares(docPath, parentDocRef) async {
  List<Future<bool>> result = [];
  for (int i = 1; i <= num_child_square; i++) {
    result.add(create_init_child_squares(docPath, parentDocRef, i));
  }
  await Future.wait(result);
}

// Todo: Change batch process!!!
Future<bool> create_init_child_squares(docPath, parentDocRef, index) async {
  final parentDocId = parentDocRef.id;
  final date = DateTime.now().toLocal().toIso8601String();
  num maxAchieveScore =
      base_max_score * pow(num_child_square - 1, max_depth - 1);

  Map<String, dynamic> trunkSquare = {
    'title': '',
    'create_date': date,
    'change_date': date,
    'parent': parentDocId,
    'max_achievement_score': maxAchieveScore,
    'done_score': 0,
    'order': index,
  };

  await FirebaseFirestore.instance
      .collection(docPath)
      .add(trunkSquare)
      .then((docRef) {
    if (index == 5) {
      return true;
    }
    num maxAchieveScore =
        base_max_score * pow(num_child_square - 1, max_depth - 2);
    for (int i = 1; i <= num_child_square; i++) {
      trunkSquare['parent'] = docRef.id;
      trunkSquare['order'] = i;
      trunkSquare['max_achievement_score'] = maxAchieveScore;
      FirebaseFirestore.instance.collection(docPath).add(trunkSquare);
    }
  });
  return true;
}
