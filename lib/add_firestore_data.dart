import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data_class.dart';

// class AddFirestoreData extends StatelessWidget {
//   final int foodId;
//   final FoodData foodData;

//   const AddFirestoreData({super.key, required this.foodId, required this.foodData});

//   @override
//   Future<Widget> build(BuildContext context) async {
//     Future createNewMotto(Map<String, dynamic> json) async {
//       DocumentReference<Map<String, dynamic>> documentReference =
//           FirebaseFirestore.instance.collection("motto_db").doc();
//       final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

//       if (!documentSnapshot.exists) {
//         await documentReference.set(json);
//       }
//     }
//       return createNewMotto(json);
//   }
// }
