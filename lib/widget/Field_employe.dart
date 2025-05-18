import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_app/widget/My_field.dart';

class FieldEmploye extends StatelessWidget {
  const FieldEmploye({
    super.key,
    required this.Queue_name,
  });

  final TextEditingController Queue_name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          Expanded(child: My_field(hint: 'Queue name', controller: Queue_name)),
          SizedBox(
            width: 15,
          ),
          SvgPicture.asset(
            'assets/add.svg',
            height: 40,
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Color(0xff872CD8),
          borderRadius: BorderRadius.circular(18)),
    );
  }
}
