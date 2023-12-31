import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/add_firestore_data.dart';
import 'package:flutter_application/data_class.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/loding.dart';

class AddFoodData extends StatefulWidget {
  final FoodData foodData;
  final int foodId;

  const AddFoodData({super.key, required this.foodData, required this.foodId});

  @override
  State<AddFoodData> createState() => _AddFoodDataState();
}

class _AddFoodDataState extends State<AddFoodData> {
  final List<String> storageOptions = ['냉장실', '냉동실', '실온'];
  final TextStyle boldStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final TextStyle hintStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
  final InputBorder borderStyle =
      const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black));
  final EdgeInsetsGeometry paddingSymmetric10 = const EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildImageSection(widget.foodData.imagePath),
          buildNameSection(widget.foodData.namePath),
          buildStorageSection(widget.foodData.selectedStorage),
          buildQuantitySection(widget.foodData.quantity),
          buildDivider(),
          buildDateSection('등록일', widget.foodData.selectedDate, () {
            _selectDate(context, widget.foodData.selectedDate, (picked) {
              setState(() {
                widget.foodData.selectedDate = picked;
              });
            });
          }),
          buildDateSection('소비기한', widget.foodData.expirationDate, () {
            _selectDate(context, widget.foodData.expirationDate, (picked) {
              setState(() {
                widget.foodData.expirationDate = picked;
              });
            });
          }),
          buildNoteSection(widget.foodData.noteController),
          buildAddButton(widget.foodId, widget.foodData),
        ],
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
                  height: 90,
                  width: 100,
                  fit: BoxFit.contain,
                );
              } else {
                return const Text("No data found");
              }
            }

            return const LoadingIndicator();
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
            value: widget.foodData.selectedStorage,
            onChanged: (String? newValue) {
              setState(() {
                widget.foodData.selectedStorage = newValue!;
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
                    if (widget.foodData.quantity > 1) {
                      widget.foodData.quantity--;
                    }
                  });
                },
              ),
              Text('${widget.foodData.quantity}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    widget.foodData.quantity++;
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
          controller: widget.foodData.noteController,
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

  Positioned buildAddButton(int foodId, FoodData foodData) {
    return Positioned(
      top: 530,
      left: 50,
      right: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AddFirestoreData(foodId: foodId, foodData: foodData)));
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
