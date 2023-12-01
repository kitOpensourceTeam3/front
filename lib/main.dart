// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:flutter_application/Items.dart' as items_app;

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
  bool isInput = true; // 로그인/회원가입 입력 화면 표시 여부
  bool isSignIn = true; // 로그인 중인지, 회원가입 중인지 여부
  bool autoLogin = false; // 자동 로그인 여부

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      email = savedEmail;
      password = savedPassword;
      signIn();
    }
  }

  signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (value.user!.emailVerified) {
          if (autoLogin) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('email', email);
            prefs.setString('password', password);
          }
          // ignore: use_build_context_synchronously
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
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
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
      Text(
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
            if (isSignIn)
              SwitchListTile(
                title: const Text('자동 로그인'),
                value: autoLogin,
                onChanged: (bool value) {
                  setState(() {
                    autoLogin = value;
                  });
                },
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
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
                            setState(() {
                              isSignIn = !isSignIn;
                              autoLogin = false;
                            });
                          }),
                  ],
                ),
              ),
            ),
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
      appBar: AppBar(title: const Text("")),
      body: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: isInput ? getInputWidget() : getResultWidget()),
    );
  }
}
