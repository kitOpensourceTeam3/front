import 'package:flutter/material.dart';

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '음식 추가',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: buildMainMenu(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainMenu() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: 8,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            onTap: () {
              // Handle button tap here
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // 버튼 라운드 하드처리
              child: Container(
                margin: const EdgeInsets.all(8),
                color: Colors.blue,
                child: Center(
                  child: Text('식품 버튼 ${index + 1}'),
                ),
              ),
            ));
      },
    );
  }
}
