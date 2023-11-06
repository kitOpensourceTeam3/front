import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
              title: Text('AppName'),
              bottom: TabBar(
                controller: controller,
                tabs: <Widget>[
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
            )));
  }
}
