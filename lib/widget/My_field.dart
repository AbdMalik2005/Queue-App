import 'package:flutter/material.dart';

class My_field extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure; // هل يتم إخفاء النص؟
  final bool obscureactive; // هل نعرض أيقونة العين؟

  const My_field({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.obscureactive = false,
  });

  @override
  State<My_field> createState() => _MyFieldState();
}

class _MyFieldState extends State<My_field> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontFamily: "Myfont",
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0, horizontal: 16.0), // <-- هنا
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.obscureactive
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    isObscured = !isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}
