// ignore_for_file: non_constant_identifier_names

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
