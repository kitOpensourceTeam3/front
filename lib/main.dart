// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application/Items.dart' as items_app;

showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  AuthWidgetState createState() => AuthWidgetState();
}

class AuthWidgetState extends State<AuthWidget> {
  final _formKey = GlobalKey<FormState>();

  late String email;
  late String password;
  bool isInput = true; //false - result
  bool isSignIn = true; //false - SingUp

  // login
  signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        print(value);
        if (value.user!.emailVerified) {
          // 로그인 성공 시, MainApp 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const items_app.MyApp()), // ItemsScreen으로 이동
          );
          showToast('login success');
        } else {
          showToast('emailVerified error');
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        // 오류수정
        showToast('user-not-found');
      } else if (e.code == 'invalid-password') {
        showToast('wrong-password');
      } else {
        print(e.code);
      }
    }
  }

  // logout
  // signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   setState(() => isInput = true);
  // }
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() => isInput = true);
  }

  void logout() {
    signOut();
  }

  // register
  signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user!.email != null) {
          FirebaseAuth.instance.currentUser?.sendEmailVerification();
          setState(() => isInput = false);
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('weak-password');
      } else if (e.code == 'email-already-in-use') {
        showToast('email-already-in-use');
      } else {
        showToast('other error');
        print(e.code);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  List<Widget> getInputWidget() {
    return [
      Text(
        // title
        isSignIn ? "로그인" : "회원가입",
        style: const TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              // <- email
              decoration: const InputDecoration(labelText: 'email'),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please enter email';
                }
                return null;
              },
              onSaved: (String? value) {
                email = value ?? "";
              },
            ),
            TextFormField(
              // <- password
              decoration: const InputDecoration(
                labelText: 'password',
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please enter password';
                }
                return null;
              },
              onSaved: (String? value) {
                password = value ?? "";
              },
            ),
          ],
        ),
      ),
      ElevatedButton(
          // <- "SignIn" : "SignUp"
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              print('email: $email, password : $password');
              (isSignIn) ? signIn() : signUp();
            }
          },
          child: Text(isSignIn ? "로그인" : "회원가입")),
      RichText(
        // go to SignUp or SignIn
        textAlign: TextAlign.right,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: isSignIn ? "회원가입" : "로그인",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() => isSignIn = !isSignIn);
                  }),
            TextSpan(
              text: ' 하러가기',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> getResultWidget() {
    String resultEmail = FirebaseAuth.instance.currentUser!.email!;
    return [
      Text(
        isSignIn
            ? "$resultEmail 로 로그인 하셨습니다.!"
            : "$resultEmail 로 회원가입 하셨습니다.! 이메일 인증을 거쳐야 로그인이 가능합니다.",
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      ElevatedButton(
          onPressed: () {
            if (isSignIn) {
              signOut();
            } else {
              setState(() {
                isInput = true;
                isSignIn = true;
              });
            }
          },
          child: Text(isSignIn ? "SignOut" : "SignIn")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auth Test")),
      body: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: isInput ? getInputWidget() : getResultWidget()),
    );
  }
}
