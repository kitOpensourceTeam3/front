// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application/Add_Food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '식품 추가',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('food_type').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('오류가 발생했습니다.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var foodType = snapshot.data!.docs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreFoodListScreen(foodTypeId: foodType['id']),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Center(
                      child: Text(foodType['name']), // name 필드의 데이터 표시
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MoreFoodListScreen extends StatelessWidget {
  final int foodTypeId;
  const MoreFoodListScreen({super.key, required this.foodTypeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('더 많은 식품 목록 - $foodTypeId'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_list')
            .where('type', isEqualTo: foodTypeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('오류가 발생했습니다.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var moreFoodData = snapshot.data!.docs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFoodScreen(food_Id: moreFoodData['id']),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  color: Colors.green, // 원하는 배경색 설정
                  child: Center(
                    child: Text(moreFoodData['name']), // 데이터 표시
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
