import 'package:chat_app/pages/home.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

// ignore: must_be_immutable
class Chatpage extends StatefulWidget {
  String name, profileurl, username;
  Chatpage({
    super.key,
    required this.name,
    required this.profileurl,
    required this.username,
  });

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  TextEditingController messagecontroller = TextEditingController();
  String? myUsername, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  getsharedpref() async {
    try {
      myUsername = await SharedPreferneceHelper().getUserName();
      myProfilePic = await SharedPreferneceHelper().getUserPic();
      myName = await SharedPreferneceHelper().getUserDisplayName();
      myEmail = await SharedPreferneceHelper().getUserEmail();

      if (myUsername != null) {
        chatRoomId = getChatRoomIdbyUsename(widget.username, myUsername!);
        setState(() {});
      } else {
        // print("Username is null");
      }
    } catch (e) {
      // Handle any errors that occur during the fetching process
      // print("Error fetching shared preferences: $e");
    }
  }

  ontheload() async {
    await getsharedpref();
    await getAndSendMessage();
    setState(() {});
  }

  getChatRoomIdbyUsename(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Widget chatMessageTile(String message, bool sendbyMe) {
    return Row(
      mainAxisAlignment:
          sendbyMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: sendbyMe
                  ? const Color.fromARGB(255, 234, 236, 240)
                  : const Color.fromARGB(255, 211, 228, 243),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: sendbyMe
                    ? const Radius.circular(24)
                    : const Radius.circular(0),
                bottomRight: sendbyMe
                    ? const Radius.circular(0)
                    : const Radius.circular(24),
              ),
            ),
            child: Text(
              message,
              style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.12,
      child: StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 90, top: 130),
              itemCount: snapshot.data.docs.length,
              reverse: true,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return chatMessageTile(
                    ds["Message"], myUsername == ds["sendBy"]);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  addMessage(bool sendClicked) {
    if (messagecontroller.text.isNotEmpty) {
      String message = messagecontroller.text;
      messagecontroller.clear();
      DateTime now = DateTime.now();
      String formatedDate = DateFormat("h:mma").format(now);

      if (myUsername != null && chatRoomId != null) {
        Map<String, dynamic> messageInfoMap = {
          "Message": message,
          "sendBy": myUsername,
          "ts": formatedDate,
          "time": FieldValue.serverTimestamp(),
          "imgUrl": myProfilePic ?? ''
        };

        messageId = messageId ?? randomAlphaNumeric(10);

        DatabaseMethods()
            .addMessage(chatRoomId!, messageId!, messageInfoMap)
            .then((value) {
          Map<String, dynamic> lastMessageInfoMap = {
            "lastMessage": message,
            "lastMessagesendBy": myUsername,
            "lastMessageSendTs": formatedDate,
            "time": FieldValue.serverTimestamp(),
          };
          DatabaseMethods()
              .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);

          if (sendClicked) {
            messageId = null;
          }
        });
      }
    }
  }

  getAndSendMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessage(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff553370),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 60.0),
          child: Stack(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 50.0),
                  height: MediaQuery.of(context).size.height / 1.12,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: chatMessage()),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ));
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Color(0xffc199cd),
                          )),
                      const SizedBox(
                        width: 90,
                      ),
                      Text(
                        widget.name,
                        style: GoogleFonts.nunito(
                            color: const Color(0xffc199cd),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 20, right: 20.0, bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    borderRadius: BorderRadius.circular(30),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: messagecontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                addMessage(true);
                              },
                              child: const Icon(Icons.send_rounded)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
