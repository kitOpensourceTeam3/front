import 'package:flutter/material.dart';

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text(
        '음식 추가',
        style: TextStyle(color: Colors.black), // 여기에서 글자 색상을 지정합니다.
      ),
      backgroundColor: Colors.white, // AppBar 배경색을 지정합니다.
      iconTheme: const IconThemeData(
        color: Colors.black, // 뒤로 가기 버튼의 색상을 검은색으로 지정합니다.
      ),
    ));
  }
}
