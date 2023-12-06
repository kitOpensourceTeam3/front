// ignore_for_file: library_private_types_in_public_api, unused_import, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application/add_food_data.dart';
import 'package:flutter_application/edit_food_data.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/data_class.dart';

class EditFoodMoreScreen extends StatefulWidget {
  final FoodEdit foodEdit;
  final String docId;

  const EditFoodMoreScreen({Key? key, required this.foodEdit, required this.docId})
      : super(key: key);

  @override
  _EditFoodMoreScreenState createState() => _EditFoodMoreScreenState();
}

class _EditFoodMoreScreenState extends State<EditFoodMoreScreen> {
  late int imagePath;
  late String namePath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchDataFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('오류: ${snapshot.error}');
        } else {
          return EditFoodData(
            imagePath: imagePath,
            namePath: namePath,
            docId: widget.docId,
            foodEdit: widget.foodEdit,
          );
        }
      },
    );
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('food_list')
          .where('id', isEqualTo: widget.foodEdit.f_id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        imagePath = querySnapshot.docs.first['img_id'];
        namePath = querySnapshot.docs.first['name'];
      } else {
        imagePath = 0;
        namePath = '';
      }
    } catch (error) {
      print('Firestore 데이터를 가져오는 중 오류 발생: $error');
    }
  }
}
