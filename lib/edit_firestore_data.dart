// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data_class.dart';
import 'package:flutter_application/items_provider.dart';
import 'package:provider/provider.dart';

class EditFirestoreData extends StatelessWidget {
  final String docId;
  final FoodEdit foodEdit;

  const EditFirestoreData(
      {super.key, required this.docId, required this.foodEdit});

  @override
  Widget build(BuildContext context) {
    Future<void> createNewFoodData() async {
      Map<String, dynamic> jsonData = {
        'uid': foodEdit.uid,
        'f_id': foodEdit.f_id,
        'quantity': foodEdit.quantity,
        'add_day': foodEdit.add_day,
        'exp_day': foodEdit.exp_day,
        'type': foodEdit.type,
        'memo': foodEdit.memo,
      };

      CollectionReference foodDataCollection =
          FirebaseFirestore.instance.collection("food_data");
      await foodDataCollection.doc(docId).update(jsonData);
    }

    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      createNewFoodData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ItemsProvider>().loadFoodData();
        Navigator.pop(context);
      });
    }

    return Container();
  }
}
