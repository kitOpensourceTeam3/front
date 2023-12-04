// ignore_for_file: library_private_types_in_public_api, unused_import, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/edit_food.dart';
import 'package:flutter_application/add_food.dart';
import 'package:flutter_application/food_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_application/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MyApp>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  late Map<String, List<DocumentSnapshot>> foodData;

  @override
  void initState() {
    super.initState();
    loadFoodData();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose(); // 위젯이 제거될 때 controller를 정리합니다.
    super.dispose();
  }

  void loadFoodData() async {
    String uid = getUserUid();
    foodData = await getFoodDataByUidAndType(uid);
    setState(() {}); // 데이터 로딩 후 UI 업데이트
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
                        AuthWidget authWidget = const AuthWidget();
                        AuthWidgetState authWidgetState =
                            authWidget.createState();
                        authWidgetState.signOut();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthWidget()),
                        );
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
                  controller: controller,
                  tabs: const <Widget>[
                    Tab(text: '냉장실'),
                    Tab(text: '냉동실'),
                    Tab(text: '실온'),
                  ],
                ),
              ),
              //add........................
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
                    // AddFoodScreen으로 화면 전환
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FoodListScreen()),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            )));
  }
}

class FoodListTab extends StatelessWidget {
  final String tabType;
  const FoodListTab({Key? key, required this.tabType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<DocumentSnapshot>>>(
      future: getFoodDataByUidAndType(getUserUid()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data![tabType]!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data?[tabType]?[index];
              print(data?['exp_day'].toDate());

              return data != null
                  ? NewTile(
                      remainingDays: calculateRemainingDays(
                        (data['add_day'])?.toDate() ?? DateTime.now(),
                        (data['exp_day'])?.toDate() ?? DateTime.now(),
                      ),
                      foodName: data['type'],
                      onEdit: () {
                        // 편집 로직
                      },
                      onDelete: () {
                        // 삭제 로직
                      },
                    )
                  : SizedBox();
            },
          );
        } else {
          return const Text('No data available');
        }
      },
    );
  }

  String calculateRemainingDays(DateTime currentDate, DateTime expDate) {
    int remaining = expDate.difference(currentDate).inDays;
    return remaining > 0 ? 'D-$remaining' : '기한 만료';
  }
}

Future<Map<String, List<DocumentSnapshot>>> getFoodDataByUidAndType(
    String uid) async {
  Map<String, List<DocumentSnapshot>> foodData = {
    'cool': [],
    'frozen': [],
    'room': [],
  };

  var querySnapshot = await FirebaseFirestore.instance
      .collection('food_data')
      .where('uid', isEqualTo: uid)
      .get();

  querySnapshot.docs.forEach((doc) {
    String type = doc['type'];

    if (foodData.containsKey(type)) {
      foodData[type]?.add(doc);
    }
  });
  return foodData;
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
                  MaterialPageRoute(
                      builder: (context) => const EditFoodScreen()),
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
