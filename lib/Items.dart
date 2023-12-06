// ignore_for_file: library_private_types_in_public_api, unused_import, file_names, avoid_print, invalid_return_type_for_catch_error

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/edit_food.dart';
import 'package:flutter_application/add_food.dart';
import 'package:flutter_application/food_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/items_provider.dart';
import 'package:flutter_application/refresh_fooddata.dart';
import 'package:provider/provider.dart';
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
                    AuthWidget authWidget = const AuthWidget();
                    AuthWidgetState authWidgetState = authWidget.createState();
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
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: '냉장실'),
                Tab(text: '냉동실'),
                Tab(text: '실온'),
              ],
            ),
          ),
          body: const TabBarView(
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
                  MaterialPageRoute(
                      builder: (context) => const FoodListScreen()),
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
    context.read<ItemsProvider>().loadFoodData();
  }

  void refreshFoodData() {
    foodDataFuture =
        RefreshFoodData.instance.getFoodDataByUidAndType(getUserUid());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemsProvider>(
      builder: (context, itemProvider, child) {
        if (itemProvider.foodData.isNotEmpty) {
          // foodData가 존재하면 ListView를 구성
          return ListView.builder(
            itemCount: itemProvider.foodData[widget.tabType]!.length,
            itemBuilder: (context, index) {
              var data = itemProvider.foodData[widget.tabType]![index];
              int id = data['f_id'];
              int quantity = data['quantity'];

              // 데이터에 기반한 각 아이템에 대한 UI 구성
              return FutureBuilder<String>(
                future: getFoodNameByFid(id),
                builder: (context, nameSnapshot) {
                  if (nameSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (nameSnapshot.hasError) {
                    return Text('Error: ${nameSnapshot.error}');
                  } else if (nameSnapshot.hasData) {
                    String foodName = nameSnapshot.data!;
                    String? docId =
                        itemProvider.foodData[widget.tabType]?[index].id;

                    // 데이터에 따라 NewTile 위젯 또는 다른 위젯 반환
                    return NewTile(
                      docId: docId!,
                      remainingDays: calculateRemainingDays(
                        (data['add_day'] as Timestamp?)!.toDate(),
                        (data['exp_day'] as Timestamp?)!.toDate(),
                      ),
                      foodName: foodName,
                      quantity: quantity,
                      onDelete: () {
                        deleteFoodData(docId);
                      },
                      onDecrease: () {
                        decreaseFoodQuantity(docId, quantity);
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
          // foodData가 비어있으면 로딩 인디케이터 표시
          return const CircularProgressIndicator();
        }
      },
    );
  }

  void decreaseFoodQuantity(String? docId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      deleteFoodData(docId);
    } else {
      await FirebaseFirestore.instance
          .collection('food_data')
          .doc(docId)
          .update({'quantity': FieldValue.increment(-1)}).then((_) {
        context.read<ItemsProvider>().loadFoodData();
        setState(() {});
      }).catchError((error) => print('Error updating document: $error'));
    }
  }

  void deleteFoodData(String? docId) async {
    await FirebaseFirestore.instance
        .collection('food_data')
        .doc(docId)
        .delete()
        .then((_) {
      print('Document successfully deleted');
      context.read<ItemsProvider>().loadFoodData();
      setState(() {}); // 상태 업데이트
    }).catchError((error) => print('Error removing document: $error'));
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

  for (var doc in querySnapshot.docs) {
    String type = doc['type'];
    foodData[type]?.add(doc);
  }
  return foodData;
}

Future<String> getFoodNameByFid(int fid) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('food_image')
      .where('id', isEqualTo: fid)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0]['name'];
  } else {
    return 'none';
  }
}

String getUserUid() {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? '';
}

class NewTile extends StatelessWidget {
  final String? docId;
  final String remainingDays;
  final String foodName;
  final int quantity;
  final Function()? onDelete;
  final Function()? onDecrease;

  const NewTile({
    required this.docId,
    super.key,
    required this.remainingDays,
    required this.foodName,
    required this.quantity,
    this.onDelete,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(foodName),
        leading: Text(
          remainingDays,
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Text('수량: $quantity'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: quantity > 1 ? onDecrease : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditFoodScreen(docId: docId!)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
