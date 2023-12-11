import 'package:flutter/material.dart';
import 'package:flutter_application/Edit_Food.dart';

class NewTile extends StatelessWidget {
  final String? docId;
  final String remainingDays;
  final String foodName;
  final int quantity;
  final Function()? onDelete;
  final Function()? onDecrease;

  const NewTile({
    required this.docId,
    super.key,
    required this.remainingDays,
    required this.foodName,
    required this.quantity,
    this.onDelete,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(foodName),
        leading: Text(
          remainingDays,
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Text('수량: $quantity'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: quantity > 1 ? onDecrease : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditFoodScreen(docId: docId!)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
