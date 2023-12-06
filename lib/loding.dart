import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeInOut(
      color: color,
      size: size,
    );
  }
}
