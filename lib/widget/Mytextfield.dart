import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  final String? title;
  final Icon? myicon;
  TextEditingController controller = TextEditingController();
   Mytextfield({super.key, this.myicon, this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: myicon,
        hintText: '$title',
        hintStyle: TextStyle(fontSize: 15),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
