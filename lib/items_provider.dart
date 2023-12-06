import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Items.dart' as items;

class ItemsProvider with ChangeNotifier {
  Map<String, List<DocumentSnapshot>> foodData = {};

  Future<void> loadFoodData() async {
    String uid = items.getUserUid();
    foodData = await items.getFoodDataByUidAndType(uid);
    notifyListeners(); // 상태 변경 알림
  }
}
