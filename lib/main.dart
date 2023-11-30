// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application/Items.dart' as items_app;

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWidget(), // <- home에 추가하여 처음부터 실행
    );
  }
}

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override


class AuthWidgetState extends State<AuthWidget> {
  final _formKey = GlobalKey<FormState>();


              // 실온 탭
              ListView(
                child