// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application/Add_Food.dart';

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

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('AppName'),
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
            children: const <Widget>[
              Center(
                child: Text(
                  'One Screen',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  'Two Screen',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  'Three Screen',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () {
                // AddFoodScreen으로 화면 전환
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                );
              },
              child: const Icon(Icons.add), // '+' 아이콘
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 우측 하단 위치
        ));
  }
}
