import 'package:chat_app/Widget/textfieldwidget.dart';
import 'package:chat_app/pages/forgot_password.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";

  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  Future<void> userlogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyEmail(email);

      if (querySnapshot.docs.isNotEmpty) {
        name = "${querySnapshot.docs[0]["Name"]}";
        username = "${querySnapshot.docs[0]["username"]}";
        pic = "${querySnapshot.docs[0]["Photo"]}";
        id = querySnapshot.docs[0].id;

        await SharedPreferneceHelper().saveUserDisplayName(name);
        await SharedPreferneceHelper().saveUserEmail(email);
        await SharedPreferneceHelper().saveUserid(id);
        await SharedPreferneceHelper().saveUserPic(pic);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Login SuccessFully",
              style: TextStyle(fontSize: 20, color: Colors.black),
            )));
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found for that email",
              style: TextStyle(fontSize: 20, color: Colors.black),
            )));
      }
    } on FirebaseException catch (e) {
      if (e.code == "user-not-found") {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found for that email",
              style: TextStyle(fontSize: 20, color: Colors.black),
            )));
      } else if (e.code == "wrong-password") {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong password",
              style: TextStyle(fontSize: 20, color: Colors.black),
            )));
      }
    }
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xff6380fb),
                            Color(0xff7f30fe),
                          ]),
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(
                              MediaQuery.of(context).size.width, 100))),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      child: Column(
                        children: [
                          Text(
                            "Sign in",
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Login to your account",
                            style: GoogleFonts.nunito(
                                color: Colors.grey.shade300,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    top: 150,
                    right: 30,
                  ),
                  child: Card(
                    elevation: 5.0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width / 1,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 30, left: 20, right: 20),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: GoogleFonts.nunito(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Textfieldwidget(
                                controller: useremailcontroller,
                                text: "Enter email",
                                sizeicon: 20,
                                preIcon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter email';
                                  }
                                  return null;
                                },
                                obscureText: false,
                                keyboard: TextInputType.emailAddress,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Password",
                                style: GoogleFonts.nunito(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Textfieldwidget(
                                text: "Enter password",
                                controller: userpasswordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter password';
                                  }
                                  return null;
                                },
                                preIcon: FontAwesomeIcons.lock,
                                suffixIcon: Icons.visibility,
                                sizeicon: 18,
                                obscureText: true,
                                keyboard: TextInputType.visiblePassword,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.orangeAccent),
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      "Forgot Password?",
                                      style: GoogleFonts.nunito(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              child: const ForgotPassword(),
                                              type: PageTransitionType.fade));
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                        const Color(0xff7f30fe),
                                      ),
                                      overlayColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.orangeAccent),
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      "Sign in",
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      if (_formkey.currentState!.validate()) {
                                        setState(() {
                                          email = useremailcontroller.text;
                                          password =
                                              userpasswordcontroller.text;
                                        });
                                      }
                                      await userlogin();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.end,
                  "Don't have an account? ",
                  style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: const SignUp(),
                            type: PageTransitionType.fade));
                  },
                  child: Text(
                    textAlign: TextAlign.end,
                    " Sign up Now!",
                    style: GoogleFonts.nunito(
                        color: Colors.purple,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
