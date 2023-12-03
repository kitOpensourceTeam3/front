// ignore_for_file: library_private_types_in_public_api, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:flutter_application/add_food_data.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/data_class.dart';

class AddFoodScreen extends StatefulWidget {
  final int foodId;

  const AddFoodScreen({super.key, required this.foodId});

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  late FoodData foodData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식품 추가하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_list')
            .where('id', isEqualTo: widget.foodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('오류가 발생했습니다.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          var foodDataSnapshot = snapshot.data!.docs.first;
          if (!snapshot.hasData) {
            return const Text('데이터가 없습니다.');
          }

          foodData = FoodData(
            imagePath: foodDataSnapshot['img_id'],
            namePath: foodDataSnapshot['name'],
            exp_date: foodDataSnapshot['exp_date'],
          );
          return AddFoodData(foodData: foodData, foodId: widget.foodId);
        },
      ),
    );
  }
}
