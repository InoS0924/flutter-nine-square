// dart
import './const_list.dart';

// third party
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// app

// some package

// 更新可能なデータ
class UserState extends ChangeNotifier {
  User? user;
  int depth = 0;
  List<String> topicList = [];
  //List<List<dynamic>> SquareList = [];

  void setUser(User newUser) {
    user = newUser;
  }

  void downStair() {
    if (depth <= max_depth) {
      depth++;
    }
  }

  void upStair() {
    if (depth > 0) {
      depth--;
    }
  }

  void pushTopic(topicId) {
    topicList.add(topicId);
  }

  String popTopic() {
    return topicList.removeLast();
  }

  void printFeatures(String pageName) {
    print("In $pageName");
    print("===Features==");
    print("Depth: $depth");
    print(topicList);
    print("=============\n\n");
  }
}
