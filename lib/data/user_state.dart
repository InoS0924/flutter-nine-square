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
  List<String> titleList = [];

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

  void pushTopic(topicId, title) {
    topicList.add(topicId);
    titleList.add(title);
  }

  List<String> popTopic() {
    return [topicList.removeLast(), titleList.removeLast()];
  }

  void printFeatures(String pageName) {
    print("In $pageName");
    print("===Features==");
    print("Depth: $depth");
    print(topicList);
    print(titleList);
    print("=============\n\n");
  }
}
