// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodData {
  int imagePath;
  int quantity;
  int exp_date;
  String namePath;
  String selectedStorage;
  DateTime selectedDate;
  DateTime expirationDate;
  TextEditingController noteController;

  FoodData({
    required this.imagePath,
    this.quantity = 1,
    required this.exp_date,
    required this.namePath,
    this.selectedStorage = '냉장고',
    DateTime? selectedDate,
    DateTime? expirationDate,
    TextEditingController? noteController,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        expirationDate = expirationDate ?? DateTime.now().add(Duration(days: exp_date)),
        noteController = noteController ?? TextEditingController();
}

class FoodEdit {
  int f_id;
  int quantity;
  String type;
  String uid;
  String memo;
  Timestamp add_day;
  Timestamp exp_day;

  FoodEdit(
      {required this.f_id,
      required this.quantity,
      required this.type,
      required this.uid,
      required this.memo,
      required this.add_day,
      required this.exp_day});
}
