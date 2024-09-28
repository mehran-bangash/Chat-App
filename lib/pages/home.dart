import 'package:chat_app/Widget/chat_text_image.dart';
import 'package:chat_app/pages/chatpage.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pre.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomStream;

  gettheSharedpref() async {
    myName = await SharedPreferneceHelper().getUserDisplayName();
    myProfilePic = await SharedPreferneceHelper().getUserPic();
    myUserName = await SharedPreferneceHelper().getUserName();
    myEmail = await SharedPreferneceHelper().getUserEmail();

    setState(() {});
  }

  ontheload() async {
    await gettheSharedpref();
     chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Access the list of documents with snapshot.data.docs
          var documents = snapshot.data.docs;
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = documents[index];
              return ChatRoomlistTile(
                lastMessage: ds["lastMessage"],
                chatRoomId: ds.id,
                myUsername: myUserName!,
                time: ds["lastMessageSendTs"],
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsename(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  var queryResultSet = [];
  var tempsearchStore = [];

  void initiatStateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempsearchStore = [];
      });
      return;
    }

    search = true;
    var captilizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        setState(() {
          for (var doc in docs.docs) {
            queryResultSet.add(doc.data());
          }
        });
      });
    } else {
      tempsearchStore = [];
      for (var element in queryResultSet) {
        if (element['username'].startsWith(captilizedValue)) {
          setState(() {
            tempsearchStore.add(element);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff553370),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, right: 20, left: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                            onChanged: (value) {
                              initiatStateSearch(value);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search User",
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      : Text(
                          "Chat App",
                          style: GoogleFonts.nunito(
                              color: const Color(0xffc199cd),
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        search = !search;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: search
                          ? GestureDetector(
                              onTap: () {
                                search = false;
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ))
                          : const Icon(
                              Icons.search,
                              color: Color((0xffc199cd)),
                            ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              height: search
                  ? MediaQuery.of(context).size.height / 1.19
                  : MediaQuery.of(context).size.height / 1.15,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                children: [
                  search
                      ? ListView(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          primary: false,
                          shrinkWrap: true,
                          children: tempsearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList(),
                        )
                      : chatRoomList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        if (myUserName == null) {
          //print(   "Login again"); // Handle the null case, maybe show an error message or request the user to log in again
          return;
        }
        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIdbyUsename(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]],
        };

        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => Chatpage(
                name: data["Name"],
                profileurl: data["Photo"],
                username: data["username"]),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data["Photo"],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                const SizedBox(
                    width: 10), // Spacing between the image and the text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data["username"],
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomlistTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;

  const ChatRoomlistTile(
      {super.key,
      required this.lastMessage,
      required this.chatRoomId,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomlistTile> createState() => _ChatRoomlistTileState();
}

class _ChatRoomlistTileState extends State<ChatRoomlistTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getthisUserInfo() async {
    try {
      username = widget.chatRoomId
          .replaceAll("_", "")
          .replaceAll(widget.myUsername, "");
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserInfo(username.toUpperCase());

      if (querySnapshot.docs.isNotEmpty) {
        // Accessing first document, ensure it's there
        var userDoc = querySnapshot.docs[0];
        name = userDoc["Name"] ?? "";
        id = userDoc["id"] ?? "";
        profilePicUrl = userDoc["Photo"] ?? "";
      } else {
        print("No user found for username: $username");
      }

      setState(() {});
    } catch (e) {
      print("Error in getthisUserInfo: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getthisUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl == ""
                ? const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: profilePicUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 70, color: Colors.red),
                    ),
                  ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textAlign: TextAlign.start,
                      username,
                      style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    widget.lastMessage,
                    style: GoogleFonts.nunito(
                        color: Colors.black45,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Text(
              textAlign: TextAlign.start,
              widget.time,
              style: GoogleFonts.nunito(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
}
