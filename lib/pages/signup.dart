import 'package:chat_app/Widget/textfieldwidget.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pre.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignupState();
}

class _SignupState extends State<SignUp> {
  String email = " ", password = "", name = "", confirmPassword = "";
  TextEditingController emailcontrollor = TextEditingController();
  TextEditingController passwordcontrollor = TextEditingController();
  TextEditingController namecontrollor = TextEditingController();
  TextEditingController confimpasswordcontrollor = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String? myName, myEmail;

  registration() async {
    if (password == confirmPassword) {
      try {
        String id = randomAlpha(10);
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String user = emailcontrollor.text.replaceAll("@gmail.com", "");
        String updateusername =
            user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();
        Map<String, dynamic> userInfoMap = {
          "Name": namecontrollor.text,
          "Email": emailcontrollor.text,
          "username": updateusername,
          "SearchKey": firstletter,
          "id": id,
          "Photo":
              'https://i02.appmifile.com/images/2019/03/06/829199af-238d-46b6-8294-525d9e6e8226.png'
        };

        await DatabaseMethods().addUserDetails(userInfoMap, id);
        await SharedPreferneceHelper().saveUserid(id).then((value) {
          if (value) {
            print("Saved successfully $value");
          } else {
            print("Failed to save");
          }
        }).catchError((error) {
          print("An error occurred: $error");
        });
        await SharedPreferneceHelper().saveUserDisplayName(namecontrollor.text);
        await SharedPreferneceHelper().saveUserEmail(emailcontrollor.text);
        await SharedPreferneceHelper().saveUserPic(
            'https://i02.appmifile.com/images/2019/03/06/829199af-238d-46b6-8294-525d9e6e8226.png');
        await SharedPreferneceHelper().saveUserName(
          emailcontrollor.text.replaceAll("@gmail.com", " ").toUpperCase(),
        );
        myName =
            await SharedPreferneceHelper().getUserDisplayName().then((value) {
          if (value != null) {
            print("Saved successfully $value");
          } else {
            print("Failed to save");
          }
        }).catchError(
          (error) {
            print("An error occurred: $error");
          },
        );
        myEmail = await SharedPreferneceHelper().getUserEmail();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Registration Succesfully",
          style: TextStyle(fontSize: 20),
        )));

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: const Home()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "weak password") {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Password Provided is too weak",
            style: TextStyle(fontSize: 20),
          )));
        } else if (e.code == "email-already-exist") {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Account Already exist",
            style: TextStyle(fontSize: 20),
          )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                      child: Column(
                        children: [
                          Text(
                            "Sign up",
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Create a new account",
                            style: GoogleFonts.nunito(
                                color: Colors.grey.shade300,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      top: 140,
                      right: 30,
                    ),
                    child: Card(
                      elevation: 5.0,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width / 1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 30, left: 20, right: 20),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name",
                                  style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Textfieldwidget(
                                  controller: namecontrollor,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                  text: "Enter name",
                                  sizeicon: 20,
                                  preIcon: Icons.person,
                                  keyboard: TextInputType.name,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
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
                                  controller: emailcontrollor,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Email';
                                    }
                                    return null;
                                  },
                                  text: "Enter email",
                                  sizeicon: 20,
                                  preIcon: Icons.email,
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
                                  controller: passwordcontrollor,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  text: "Enter password",
                                  preIcon: FontAwesomeIcons.lock,
                                  sizeicon: 18,
                                  suffixIcon: Icons.visibility,
                                  keyboard: TextInputType.visiblePassword,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Confirm password",
                                  style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Textfieldwidget(
                                  controller: confimpasswordcontrollor,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Confirm password';
                                    }
                                    return null;
                                  },
                                  text: "Confirm password",
                                  sizeicon: 20,
                                  suffixIcon: Icons.visibility,
                                  preIcon: Icons.check_circle,
                                  keyboard: TextInputType.visiblePassword,
                                ),
                                const SizedBox(
                                  height: 40,
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
                                    InkWell(
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () {},
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.orange),
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  width: 250,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color(0xff7f30fe),
                      ),
                      overlayColor:
                          WidgetStateProperty.all<Color>(Colors.orangeAccent),
                    ),
                    child: Text(
                      textAlign: TextAlign.end,
                      "Sign Up",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          name = namecontrollor.text;
                          email = emailcontrollor.text;
                          password = passwordcontrollor.text;
                          confirmPassword = confimpasswordcontrollor.text;
                        });
                        registration();
                        // ignore: use_build_context_synchronously
                        if (myName != null && myEmail != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                            "save name and Email Succesfully",
                            style: TextStyle(
                                fontSize: 20, color: Colors.greenAccent),
                          )));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                            "NOt",
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          )));
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
