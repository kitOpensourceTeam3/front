// ignore_for_file: library_private_types_in_public_api, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:flutter_application/add_food_data.dart';
import 'package:flutter_application/edit_food_more.dart';
import 'package:flutter_application/edit_food_data.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/data_class.dart';
import 'package:flutter_application/loding.dart';

class EditFoodScreen extends StatefulWidget {
  final String docId;

  const EditFoodScreen({super.key, required this.docId});

  @override
  _EditFoodScreenState createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  late FoodEdit foodEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식품 수정하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('food_data').doc(widget.docId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('No data found.');
          }

          var foodDataSnapshot = snapshot.data!;
          foodEdit = FoodEdit(
            f_id: foodDataSnapshot['f_id'],
            quantity: foodDataSnapshot['quantity'],
            type: foodDataSnapshot['type'],
            uid: foodDataSnapshot['uid'],
            memo: foodDataSnapshot['memo'],
            add_day: foodDataSnapshot['add_day'],
            exp_day: foodDataSnapshot['exp_day'],
          );
          return EditFoodMoreScreen(foodEdit: foodEdit, docId: widget.docId);
        },
      ),
    );
  }
}
