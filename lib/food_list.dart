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
            return Text('오류가 발생했습니다.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var foodType = snapshot.data!.docs[index];
              return InkWell(
                onTap: () {
                  // 버튼 클릭 시 동작
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddFoodScreen()),
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
