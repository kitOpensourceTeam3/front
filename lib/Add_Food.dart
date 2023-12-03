// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/data_class.dart';
import 'package:flutter_application/food_data_stream_builder.dart';

class AddFoodScreen extends StatefulWidget {
  final int food_Id;

  const AddFoodScreen({Key? key, required this.food_Id}) : super(key: key);

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final List<String> storageOptions = ['냉장고', '냉동고', '상온'];

  final TextStyle boldStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final TextStyle hintStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
  final InputBorder borderStyle =
      const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black));
  final EdgeInsetsGeometry paddingSymmetric10 = const EdgeInsets.symmetric(horizontal: 10);

  late FoodData foodData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식품 추가하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FoodDataStreamBuilder(
        foodId: widget.food_Id,
        builder: (foodData) {
          this.foodData = foodData;

          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                buildImageSection(foodData.imagePath),
                buildNameSection(foodData.namePath),
                buildStorageSection(foodData.selectedStorage),
                buildQuantitySection(foodData.quantity),
                buildDivider(),
                buildDateSection('등록일', foodData.selectedDate, () {
                  _selectDate(context, foodData.selectedDate, (picked) {
                    setState(() {
                      foodData.selectedDate = picked;
                    });
                  });
                }),
                buildDateSection('소비기한', foodData.expirationDate, () {
                  _selectDate(context, foodData.expirationDate, (picked) {
                    setState(() {
                      foodData.expirationDate = picked;
                    });
                  });
                }),
                buildNoteSection(foodData.noteController),
                buildAddButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Positioned buildImageSection(int imagePath) {
    return Positioned(
      top: 50,
      left: 50,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(230, 230, 230, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('food_image')
              .where('id', isEqualTo: imagePath)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.connectionState == ConnectionState.active) {
              var imageData = snapshot.data!.docs;

              if (imageData.isNotEmpty) {
                String imagePath = imageData.first['f_name'] as String;

                return Image.network(
                  imagePath,
                  width: 100,
                  fit: BoxFit.cover,
                );
              } else {
                return const Text("No data found");
              }
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Positioned buildNameSection(String imageName) {
    return Positioned(
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
              hintStyle: hintStyle,
              border: borderStyle,
              enabledBorder: borderStyle,
              focusedBorder: borderStyle,
              contentPadding: paddingSymmetric10,
            ),
            style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
          ),
        ),
      ),
    );
  }

  Positioned buildStorageSection(String selectedStorage) {
    return Positioned(
      top: 160,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('보관장소', style: boldStyle),
          DropdownButton<String>(
            value: foodData.selectedStorage,
            onChanged: (String? newValue) {
              setState(() {
                foodData.selectedStorage = newValue!;
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
    );
  }

  Positioned buildQuantitySection(int quantity) {
    return Positioned(
      top: 200,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('수량', style: boldStyle),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (foodData.quantity > 1) {
                      foodData.quantity--;
                    }
                  });
                },
              ),
              Text('${foodData.quantity}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    foodData.quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Positioned buildDivider() {
    return const Positioned(
      top: 240,
      left: 50,
      right: 50,
      child: Divider(color: Colors.grey, thickness: 1),
    );
  }

  Positioned buildDateSection(String title, DateTime date, VoidCallback onPressed) {
    return Positioned(
      top: title == '등록일' ? 260 : 300,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: boldStyle),
          TextButton(
            onPressed: onPressed,
            child: Text(
              DateFormat('yyyy-MM-dd').format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Positioned buildNoteSection(TextEditingController noteController) {
    return Positioned(
      top: 400,
      left: 50,
      right: 50,
      child: Container(
        height: 120,
        padding: paddingSymmetric10,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextField(
          controller: foodData.noteController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: '메모를 입력하세요',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Positioned buildAddButton() {
    return Positioned(
      top: 530,
      left: 50,
      right: 50,
      child: ElevatedButton(
        onPressed: () {
          // 여기에 Firestore에 데이터 추가하는 로직 추가
          // foodData를 이용하여 필요한 데이터를 Firestore에 저장
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: const Text('추가'),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, DateTime initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }
}
