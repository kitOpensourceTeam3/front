import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위해 intl 패키지를 추가합니다.

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  String imagePath = 'images/cooking/salad.png';
  String selectedStorage = '냉장실'; // 초기 선택된 보관장소 값
  final List<String> storageOptions = ['냉장실', '냉동실', '상온실']; // 보관장소 옵션들
  int quantity = 1; // 초기 수량 값
  DateTime? selectedDate; // 선택된 등록일 날짜를 저장할 변수
  DateTime? expirationDate; // 선택된 소비기한 날짜를 저장할 변수
  TextEditingController noteController = TextEditingController(); // 메모를 위한 컨트롤러

  @override
  Widget build(BuildContext context) {
    String imageName = imagePath.split('/').last.split('.').first;
    String food = 'cooking';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '식품 추가하기',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 50,
              left: 50,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(230, 230, 230, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 180,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  food,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 170,
              right: 50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white.withOpacity(0.5),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: imageName,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 160,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '보관장소',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedStorage,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStorage = newValue!;
                      });
                    },
                    items: storageOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 200,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '수량',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 240, // 이전 요소들 아래에 적절한 간격을 두세요.
              left: 50,
              right: 50,
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
             Positioned(
              top: 260, // 구분선 아래에 적절한 간격을 두세요.
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '등록일',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? '날짜 선택'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 300, // '등록일' 선택기 아래에 적절한 간격을 두세요.
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '소비기한',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: expirationDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != expirationDate) {
                        setState(() {
                          expirationDate = picked;
                        });
                      }
                    },
                    child: Text(
                      expirationDate == null
                          ? '날짜 선택'
                          : DateFormat('yyyy-MM-dd').format(expirationDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 메모 입력 공간
            Positioned(
              top: 400, // '소비기한' 선택기 아래에 적절한 간격을 두세요.
              left: 50,
              right: 50,
              child: Container(
                height: 120, // 메모 입력 공간의 높이를 100픽셀로 설정
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // 회색 배경
                  borderRadius: BorderRadius.circular(5), // 모서리를 둥글게
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: null, // 무제한 줄 수
                  keyboardType: TextInputType.multiline, // 여러 줄 입력 가능
                  decoration: const InputDecoration(
                    hintText: '메모를 입력하세요',
                    border: InputBorder.none, // 테두리 없음
                    contentPadding: EdgeInsets.symmetric(vertical: 10), // 상하 패딩 추가
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // '추가' 버튼
            Positioned(
              top: 530, // 메모 입력 공간 아래에 적절한 간격을 두세요.
              left: 50,
              right: 50,
              child: ElevatedButton(
                onPressed: () {
                  // '추가' 버튼이 눌렸을 때의 동작을 구현하세요.
                  // 예를 들어, 입력된 데이터를 서버에 전송하거나 로컬 데이터베이스에 저장할 수 있습니다.
                },
                child: const Text('추가'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0), // 버튼 패딩을 지정합니다.
                  textStyle: const TextStyle(fontSize: 18), // 버튼 텍스트 스타일을 지정합니다.
                  primary: Colors.blue, // 버튼 색상을 지정합니다.
                   shape: RoundedRectangleBorder( // 버튼외곽선의 모양
                  borderRadius: BorderRadius.circular(20.0),
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