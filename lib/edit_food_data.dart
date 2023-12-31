import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data_class.dart';
import 'package:flutter_application/edit_firestore_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/loding.dart';

class EditFoodData extends StatefulWidget {
  final int imagePath;
  final String namePath;
  final FoodEdit foodEdit;
  final String docId;

  const EditFoodData(
      {super.key,
      required this.imagePath,
      required this.namePath,
      required this.foodEdit,
      required this.docId});

  @override
  State<EditFoodData> createState() => _EditFoodDataState();
}

class _EditFoodDataState extends State<EditFoodData> {
  final List<String> storageOptions = ['냉장실', '냉동실', '실온'];
  final TextStyle boldStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final TextStyle hintStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
  final InputBorder borderStyle =
      const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black));
  final EdgeInsetsGeometry paddingSymmetric10 = const EdgeInsets.symmetric(horizontal: 10);

  late String storageType = widget.foodEdit.type;
  late String memoString = widget.foodEdit.memo;
  late DateTime selectedDate = widget.foodEdit.add_day.toDate();
  late DateTime expirationDate = widget.foodEdit.exp_day.toDate();
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    switch (storageType) {
      case 'cool' || '냉장실':
        storageType = '냉장실';
        break;
      case 'frozen' || '냉동실':
        storageType = '냉동실';
        break;
      case 'room' || '실온':
        storageType = '실온';
        break;
      default:
        storageType = 'unknown';
        break;
    }
    noteController.text = memoString;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildImageSection(widget.imagePath),
          buildNameSection(widget.namePath),
          buildStorageSection(storageType),
          buildQuantitySection(widget.foodEdit.quantity),
          buildDivider(),
          buildDateSection('등록일', selectedDate, () {
            _selectDate(context, selectedDate, (picked) {
              setState(() {
                selectedDate = picked;
              });
            });
          }),
          buildDateSection('소비기한', expirationDate, () {
            _selectDate(context, expirationDate, (picked) {
              setState(() {
                expirationDate = picked;
              });
            });
          }),
          buildNoteSection(noteController),
          buildEditButton(widget.docId, widget.foodEdit),
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
            value: selectedStorage,
            onChanged: (String? newValue) {
              setState(() {
                storageType = newValue!;
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
                    if (widget.foodEdit.quantity > 1) {
                      widget.foodEdit.quantity--;
                    }
                  });
                },
              ),
              Text('${widget.foodEdit.quantity}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    widget.foodEdit.quantity++;
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
          controller: noteController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: '메모를 입력하세요',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: (String? newValue) {
            memoString = newValue!;
          },
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Positioned buildEditButton(String docId, FoodEdit foodEdit) {
    return Positioned(
      top: 530,
      left: 50,
      right: 50,
      child: ElevatedButton(
        onPressed: () {
          foodEdit.add_day = Timestamp.fromDate(selectedDate);
          foodEdit.exp_day = Timestamp.fromDate(expirationDate);
          foodEdit.memo = noteController.text;
          switch (storageType) {
            case '냉장실':
              foodEdit.type = 'cool';
              break;
            case '냉동실':
              foodEdit.type = 'frozen';
              break;
            case '실온':
              foodEdit.type = 'room';
              break;
            default:
              foodEdit.type = 'unknown';
              break;
          }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EditFirestoreData(docId: docId, foodEdit: foodEdit)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: const Text('수정'),
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
