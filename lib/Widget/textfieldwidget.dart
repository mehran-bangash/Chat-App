import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Textfieldwidget extends StatefulWidget {
  final String text;
  final IconData preIcon;
  final String? Function(String?)? validator;
  final double sizeicon;
  final bool? obscureText;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboard;

  const Textfieldwidget(
      {super.key,
      required this.text,
      required this.sizeicon,
      required this.preIcon,
      this.obscureText,
      required this.keyboard,
      this.suffixIcon,
      this.validator,
      this.controller});

  @override
  State<Textfieldwidget> createState() => _TextfieldwidgetState();
}

class _TextfieldwidgetState extends State<Textfieldwidget> {
  final FocusNode _focusNode = FocusNode();
  bool icon = true;
  bool _obscureText = false;
  bool suffixcolor = false;

  void toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          icon = false;
          suffixcolor = true;
        });
      } else {
        setState(() {
          icon = true;
          suffixcolor = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Default validator method
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          validator: widget.validator ?? _defaultValidator,
          keyboardType: widget.keyboard,
          obscureText: widget.obscureText != null ? _obscureText : false,
          focusNode: _focusNode,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
              suffixIcon: widget.obscureText != null
                  ? GestureDetector(
                      onTap: toggleObscureText,
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: suffixcolor
                            ? Colors.orange
                            : const Color(0xff6380fb),
                      ),
                    )
                  : null,
              hintText: widget.text,
              hintStyle:
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
              prefixIcon: icon
                  ? Icon(
                      widget.preIcon,
                      size: widget.sizeicon,
                      color: const Color(0xff6380fb),
                    )
                  : null,
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.orange)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black)),
              fillColor: Colors.white),
        ),
      ],
    );
  }
}
