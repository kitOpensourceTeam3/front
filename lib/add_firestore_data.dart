import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data_class.dart';
import 'package:flutter_application/items_provider.dart';
import 'package:provider/provider.dart';

class AddFirestoreData extends StatelessWidget {
  final int foodId;
  final FoodData foodData;

  const AddFirestoreData({super.key, required this.foodId, required this.foodData});

  @override
  Widget build(BuildContext context) {
    Future<void> createNewFoodData(String uid) async {
      String storageType;
      switch (foodData.selectedStorage) {
        case '냉장실':
          storageType = 'cool';
          break;
        case '냉동실':
          storageType = 'frozen';
          break;
        case '실온':
          storageType = 'room';
          break;
        default:
          storageType = 'unknown';
          break;
      }

      Map<String, dynamic> jsonData = {
        'uid': uid,
        'f_id': foodId,
        'quantity': foodData.quantity,
        'add_day': Timestamp.fromDate(foodData.selectedDate),
        'exp_day': Timestamp.fromDate(foodData.expirationDate),
        'type': storageType,
        'memo': foodData.noteController.text,
      };

      CollectionReference foodDataCollection = FirebaseFirestore.instance.collection("food_data");
      await foodDataCollection.add(jsonData);
    }

    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      createNewFoodData(uid);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ItemsProvider>().loadFoodData();
        Navigator.pop(context, true);
      });
    }

    return Container();
  }
}
