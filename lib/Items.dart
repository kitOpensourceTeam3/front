// ignore_for_file: library_private_types_in_public_api, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:flutter_application/food_list.dart';
import 'package:flutter_application/edit_food.dart';
import 'package:flutter_application/add_food.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_application/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('냉장고를 부탁해'),
            actions: <Widget>[
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                onSelected: (value) {
                  if (value == 'logout') {
                    signOut();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'로그아웃'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: 'logout',
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: TabBar(
              tabs: const <Widget>[
                Tab(text: '냉장실'),
                Tab(text: '냉동실'),
                Tab(text: '실온'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              FoodListTab(tabType: 'cool'),
              FoodListTab(tabType: 'frozen'),
              FoodListTab(tabType: 'room'),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodListScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class FoodListTab extends StatefulWidget {
  final String tabType;
  const FoodListTab({Key? key, required this.tabType}) : super(key: key);

  @override
  _FoodListTabState createState() => _FoodListTabState();
}

class _FoodListTabState extends State<FoodListTab> {
  late Future<Map<String, List<DocumentSnapshot>>> foodDataFuture;

  @override
  void initState() {
    super.initState();
    refreshFoodData();
  }

  void refreshFoodData() {
    foodDataFuture = getFoodDataByUidAndType(getUserUid());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<DocumentSnapshot>>>(
      future: foodDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data![widget.tabType]!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data![widget.tabType]![index];
              int id = data['f_id'];

              return FutureBuilder<String>(
                future: getFoodNameByFid(id),
                builder: (context, nameSnapshot) {
                  if (nameSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (nameSnapshot.hasError) {
                    return Text('Error: ${nameSnapshot.error}');
                  } else if (nameSnapshot.hasData) {
                    String foodName = nameSnapshot.data!;

                    return NewTile(
                      remainingDays: calculateRemainingDays(
                        (data['add_day'] as Timestamp?)!.toDate(),
                        (data['exp_day'] as Timestamp?)!.toDate(),
                      ),
                      foodName: foodName,
                      onEdit: () {
                        // 편집 로직
                      },
                      onDelete: () {
                        String? docId = snapshot.data?[widget.tabType]?[index].id;
                        deleteFoodData(docId);
                      },
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              );
            },
          );
        } else {
          return const Text('No data available');
        }
      },
    );
  }

  void deleteFoodData(String? docId) async {
    await FirebaseFirestore.instance.collection('food_data').doc(docId).delete().then((_) {
      print('Document successfully deleted');
      refreshFoodData(); // 데이터 삭제 후 화면 새로고침
      setState(() {}); // 상태 업데이트
    }).catchError((error) => print('Error removing document: $error'));
  }

  String calculateRemainingDays(DateTime currentDate, DateTime expDate) {
    int remaining = expDate.difference(currentDate).inDays;
    return remaining > 0 ? 'D-$remaining' : '기한 만료';
  }
}

Future<Map<String, List<DocumentSnapshot>>> getFoodDataByUidAndType(String uid) async {
  Map<String, List<DocumentSnapshot>> foodData = {
    'cool': [],
    'frozen': [],
    'room': [],
  };

  var querySnapshot =
      await FirebaseFirestore.instance.collection('food_data').where('uid', isEqualTo: uid).get();

  querySnapshot.docs.forEach((doc) {
    String type = doc['type'];

    if (foodData.containsKey(type)) {
      foodData[type]?.add(doc);
    }
  });
  return foodData;
}

Future<String> getFoodNameByFid(int fid) async {
  var querySnapshot =
      await FirebaseFirestore.instance.collection('food_image').where('id', isEqualTo: fid).get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0]['name'];
  } else {
    return 'none';
  }
}

String getUserUid() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String uid = user.uid;
    return uid;
  } else {
    return '';
  }
}

class NewTile extends StatelessWidget {
  final String remainingDays;
  final String foodName;
  final Function()? onEdit;
  final Function()? onDelete;

  const NewTile({
    super.key,
    required this.remainingDays,
    required this.foodName,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(foodName),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              remainingDays,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditFoodScreen()),
                );
              },
            ),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
