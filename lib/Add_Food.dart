import 'package:flutter/material.dart';

class AddFoodScreen extends StatelessWidget {
  const AddFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이미지 경로를 문자열로 저장합니다.
    String imagePath = 'images/cooking/salad.png';
    // 파일 확장자를 제거합니다.
    String imageName = imagePath.split('/').last.split('.').first;
    String food = 'cooking';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '새로운 식품',
          style: TextStyle(color: Colors.black), // 여기에서 글자 색상을 지정합니다.
        ),
        backgroundColor: Colors.white, // AppBar 배경색을 지정합니다.
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로 가기 버튼의 색상을 검은색으로 지정합니다.
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center, // Stack 내의 모든 자식들을 중앙에 배치합니다.
          children: [
            Positioned(
              top: 50,
              left: 50, // Container를 Stack의 상단에 배치합니다.
              child: Container(
                padding: const EdgeInsets.all(10.0), // Container에 패딩을 줍니다.
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(230, 230, 230, 1), // Container 배경색을 RGB로 지정합니다.
                  borderRadius: BorderRadius.circular(10), // Container 모서리를 둥글게 합니다.
                ),
                child: Image.asset(
                  imagePath,
                  width: 100, // 이미지의 크기를 지정합니다.
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 180,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(8.0), // 텍스트 주변에 패딩을 추가합니다.
                child: Text(
                  food, // 파일 이름을 텍스트로 출력합니다.
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 170,
              right: 50, // TextField에 너비를 제공합니다.
              child: Padding(
                padding: const EdgeInsets.all(8.0), // 텍스트 주변에 패딩을 추가합니다.
                child: Container(
                  color: Colors.white.withOpacity(0.5), // 텍스트의 배경색을 지정합니다.
                  child: TextField(
                    // TextField 위젯을 사용합니다.
                    decoration: InputDecoration(
                      hintText: imageName, // 입력란에 표시될 텍스트를 지정합니다.
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold, // 힌트 텍스트를 진하게 표시합니다.
                        color: Colors.black, // 힌트 텍스트 색상을 설정합니다.
                      ),
                      border: const UnderlineInputBorder(
                        // 밑줄을 추가합니다.
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        // 기본 상태의 밑줄을 설정합니다.
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        // 포커스 상태의 밑줄을 설정합니다.
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10), // 내부 패딩을 추가합니다.
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto', // 글씨체를 변경합니다. 사용 가능한 글씨체로 변경해야 합니다.
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
