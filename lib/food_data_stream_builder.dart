import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data_class.dart';

class FoodDataStreamBuilder extends StatelessWidget {
  final int foodId;
  final Widget Function(FoodData foodData) builder;

  const FoodDataStreamBuilder({super.key, required this.foodId, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('food_list').doc(foodId.toString()).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('오류가 발생했습니다.');
        }

        var foodDataSnapshot = snapshot.data!;
        var foodData = FoodData(
          imagePath: foodDataSnapshot['img_id'],
          namePath: foodDataSnapshot['name'],
          exp_date: foodDataSnapshot['exp_date'],
        );

        return builder(foodData);
      },
    );
  }
}
