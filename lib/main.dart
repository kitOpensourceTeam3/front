// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application/Edit_Food.dart';
import 'package:flutter_application/New_Food.dart';
import 'package:flutter_application/Add_Food.dart';
import 'package:flutter_application/food_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController controller;
  List<NewTile> fridgeTiles = []; //아마 냉장실 리스트타일들 관리하는 리스트

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  void deleteTile(NewTile tile) {
    setState(() {
      fridgeTiles.remove(tile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('냉장고를 부탁해'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh), //화면refresh. 추가 기능 구현 필요
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search), //돋보기. 추가 기능 구현 필요
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert), // 추가기능 구현 필요
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: controller,
              tabs: const <Widget>[
                Tab(text: '냉장고'),
                Tab(text: '냉동실'),
                Tab(text: '실온'),
              ],
            ),
          ),
          //add........................
          body: TabBarView(
            controller: controller,
            children: <Widget>[
              // 냉장고 탭
              ListView(
                children: <Widget>[
                  NewTile(remainingDays: 'D-7', foodName: '식품 1'),
                  NewTile(remainingDays: 'D-7', foodName: '식품 2')
                ],
              ),

              // 냉동실 탭
              ListView(
                children: <Widget>[],
              ),

              // 실온 탭
              ListView(
                children: <Widget>[],
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () {
                // AddFoodScreen으로 화면 전환
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodListScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
}

class NewTile extends StatelessWidget {
  final String remainingDays;
  final String foodName;
  final Function()? onEdit;
  final Function()? onDelete;

  NewTile({
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
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditFoodScreen()),
                );
              },
            ),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
