import 'package:flutter/material.dart';
import 'package:flutter_application/Add_Food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  int? selectedFoodTypeId;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 첫 번째 그리드뷰
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('food_type').orderBy('id').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('오류가 발생했습니다.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 4, // 세로 여백 조정
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var foodType = snapshot.data!.docs[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedFoodTypeId = foodType['id'];
                        });
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
            // 가로선 추가
            if (selectedFoodTypeId != null)
              const Divider(
                color: Colors.grey,
                thickness: 2,
                height: 20,
              ),
            // 두 번째 확장형 그리드뷰
            if (selectedFoodTypeId != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('food_list')
                    .where('type', isEqualTo: selectedFoodTypeId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('오류가 발생했습니다.');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 4, // 세로 여백 조정
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
                          color: Colors.green,
                          child: Center(
                            child: Text(moreFoodData['name']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
