import 'package:flutter/material.dart';

class FoodData {
  int imagePath;
  int quantity;
  int expdate;
  String namePath;
  String selectedStorage;
  DateTime selectedDate;
  DateTime expirationDate;
  TextEditingController noteController;

  FoodData({
    required this.imagePath,
    this.quantity = 1,
    required this.expdate,
    required this.namePath,
    this.selectedStorage = '냉장고',
    DateTime? selectedDate,
    DateTime? expirationDate,
    TextEditingController? noteController,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        expirationDate = expirationDate ?? DateTime.now().add(Duration(days: expdate)),
        noteController = noteController ?? TextEditingController();
}
