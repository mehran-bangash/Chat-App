import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatTextImage extends StatelessWidget {
  final String text;
  final double? imageheight;
  final double? imagewidth;
  final String nameText;
  final String chatText;
  final String timeText;

  const ChatTextImage(
      {super.key,
      required this.text,
      this.imageheight,
      this.imagewidth,
      required this.nameText,
      required this.chatText,
      required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.asset(
            text,
            height: imageheight ?? 70,
            width: imagewidth ?? 70,
            fit: BoxFit.cover,
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
                  nameText,
                  style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              textAlign: TextAlign.start,
              chatText,
              style: GoogleFonts.nunito(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          textAlign: TextAlign.start,
          timeText,
          style: GoogleFonts.nunito(
              color: Colors.black45, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
