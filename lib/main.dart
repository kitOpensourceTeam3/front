// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:flutter_application/Items.dart' as items_app;
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      title: '냉장고를 부탁해',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWidget(),
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
  bool isLoading = false; // 로딩 상태 변수 추가

  signIn() async {
    try {
      setState(() => isLoading = true); // 로딩 시작

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const items_app.MyApp()),
          );
        } else {
          _showErrorDialog('이메일 인증이 필요합니다.');
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = '로그인 오류가 발생했습니다.';
      if (e.code == 'invalid-login-credentials') {
        errorMessage = '이메일 또는 비밀번호가 틀렸습니다.';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 형식입니다.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = '너무 많은 요청이 감지되었습니다. 잠시 후 다시 시도해주세요.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() => isLoading = false); // 로딩 종료
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() => isInput = true);
  }

  signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user!.email != null) {
          FirebaseAuth.instance.currentUser?.sendEmailVerification();
          setState(() => isInput = false);
          _showDialog('회원가입 성공!', '이메일 인증을 확인해주세요.');
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = '회원가입 실패: ${e.message}';
      if (e.code == 'invalid-email') {
        errorMessage = '잘못된 이메일 형식입니다.';
      } else if (e.code == 'weak-password') {
        errorMessage = '보안에 취약한 비밀번호입니다.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일입니다.';
      }
      _showDialog('회원가입 실패', errorMessage);
    } catch (e) {
      _showDialog('오류', '오류가 발생했습니다.');
      print(e.toString());
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> getInputWidget() {
    return [
      Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return 'Please enter email';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? "",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return 'Please enter password';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? "",
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              print('email: $email, password : $password');
              (isSignIn) ? signIn() : signUp();
            }
          },
          child: Text(isSignIn ? "로그인" : "회원가입"),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: isSignIn ? "계정이 없으신가요?" : "계정이 있으신가요?",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() => isSignIn = !isSignIn);
                    }),
            ],
          ),
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
    String imagePath = 'images/Logo/AppLogo.png'; // 이미지 경로 정의

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSignIn ? "로그인" : "회원가입",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(1.0), // 이미지 주변의 여백을 설정
              child: Image.asset(imagePath,
                  fit: BoxFit.cover, // 이미지를 적절하게 조정
                  width: 200, // 이미지의 너비 설정 (원하는 크기로 조정)
                  height: 200),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment(0, -1),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (isLoading)
                      const SpinKitThreeInOut(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    if (!isLoading) ...(isInput ? getInputWidget() : getResultWidget()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
