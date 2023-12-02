// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  final int food_Id;

  const AddFoodScreen({super.key, required this.food_Id});
  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  String imagePath = 'images/cooking/salad.png';
  String selectedStorage = '냉장고';
  final List<String> storageOptions = ['냉장고', '냉동고', '상온'];
  int quantity = 1;
  DateTime selectedDate = DateTime.now();
  DateTime? expirationDate;
  TextEditingController noteController = TextEditingController();

  final TextStyle boldStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final TextStyle hintStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
  final InputBorder borderStyle =
      const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black));
  final EdgeInsetsGeometry paddingSymmetric10 = const EdgeInsets.symmetric(horizontal: 10);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식품 추가하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildImageSection(),
            buildNameSection(),
            buildStorageSection(),
            buildQuantitySection(),
            buildDivider(),
            buildDateSection('등록일', selectedDate),
            buildDateSection('소비기한', expirationDate),
            buildNoteSection(),
            buildAddButton(),
          ],
        ),
      ),
    );
  }

  Positioned buildImageSection() {
    return Positioned(
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
    );
  }

  Positioned buildNameSection() {
    String imageName = imagePath.split('/').last.split('.').first;
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

  Positioned buildStorageSection() {
    return Positioned(
      top: 160,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('보관장소', style: boldStyle),
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
    );
  }

  Positioned buildQuantitySection() {
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
                    if (quantity > 1) {
                      quantity--;
                    }
                  });
                },
              ),
              Text('$quantity', style: const TextStyle(fontSize: 16)),
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

  Positioned buildDateSection(String title, DateTime? date) {
    return Positioned(
      top: title == '등록일' ? 260 : 300,
      left: 50,
      right: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: boldStyle),
          TextButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != date) {
                setState(() {
                  if (title == '등록일') {
                    selectedDate = picked;
                  } else {
                    expirationDate = picked;
                  }
                });
              }
            },
            child: Text(
              date == null ? '날짜 선택' : DateFormat('yyyy-MM-dd').format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Positioned buildNoteSection() {
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
          controller: noteController,
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
        onPressed: () {},
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
}
