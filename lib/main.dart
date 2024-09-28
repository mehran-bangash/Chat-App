import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/signin.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyBtwDMgHz8jjxzPHR85Haz2wmUIYH2RsZ4",
    appId: "1:657166757795:android:a4d3b1dc9ab8c634b3f416",
    messagingSenderId: "657166757795",
    projectId: "chatapp-27a4b",
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: AuthMethod().getCurrentuser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return const Home();
          } else {
            return const SignUp();
          }
        },
      ),
    );
  }
}
