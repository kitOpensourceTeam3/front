import 'package:cloud_firestore/cloud_firestore.dart';

class RefreshFoodData {
  RefreshFoodData._internal();
  static final instance = RefreshFoodData._internal();

  Future<Map<String, List<DocumentSnapshot>>> getFoodDataByUidAndType(String uid) async {
    Map<String, List<DocumentSnapshot>> foodData = {
      'cool': [],
      'frozen': [],
      'room': [],
    };

    var querySnapshot =
        await FirebaseFirestore.instance.collection('food_data').where('uid', isEqualTo: uid).get();

    for (var doc in querySnapshot.docs) {
      String type = doc['type'];
      foodData[type]?.add(doc);
    }
    return foodData;
  }
}
