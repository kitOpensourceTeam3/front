import 'package:flutter/material.dart';
import 'package:flutter_application/add_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/main.dart' as main;

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  int? selectedFoodTypeId;

  Future<String> _getImageLink(String imgId) async {
    var document = await FirebaseFirestore.instance.collection('food_image').doc(imgId).get();
    return document.data()?['f_name'] ?? ''; // 이미지 링크 반환, 없으면 빈 문자열 반환
  }

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
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('food_type').orderBy('id').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('오류가 발생했습니다.');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const main.LoadingIndicator();
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var foodType = snapshot.data!.docs[index];
                      String imgId = foodType['img_id'].toString();

                      return FutureBuilder<String>(
                        future: _getImageLink(imgId),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (imageSnapshot.hasError || imageSnapshot.data!.isEmpty) {
                            return const Icon(Icons.error);
                          }

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedFoodTypeId = foodType['id'];
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Image.network(
                                        imageSnapshot.data!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        foodType['name'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
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
                    return const main.LoadingIndicator();
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var moreFoodData = snapshot.data!.docs[index];
                      String imgId = moreFoodData['img_id'].toString();

                      return FutureBuilder<String>(
                        future: _getImageLink(imgId),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (imageSnapshot.hasError || imageSnapshot.data!.isEmpty) {
                            return const Icon(Icons.error);
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFoodScreen(foodId: moreFoodData['id']),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Image.network(
                                      imageSnapshot.data!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                      moreFoodData['name'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
