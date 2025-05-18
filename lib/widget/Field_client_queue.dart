import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_app/screens/provider/JoinFun.dart';
import 'package:project_app/widget/My_field.dart';

class Field_Client_queue extends StatefulWidget {
  const Field_Client_queue({
    super.key,
    required this.Queue_code,
  });
  final TextEditingController Queue_code;

  @override
  State<Field_Client_queue> createState() => _Field_Client_queueState();
}

class _Field_Client_queueState extends State<Field_Client_queue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              scanQRCode(context);
            },
            child: SvgPicture.asset(
              'assets/barcode.svg',
              height: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child:
                  My_field(hint: 'Queue code', controller: widget.Queue_code)),
          SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () async {
              print('object');
              await JoinQeueu(widget.Queue_code.text , context);
              setState(() {
                widget.Queue_code.text = '';
              });
            },
            child: SvgPicture.asset(
              'assets/add.svg',
              height: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
      margin: EdgeInsets.all(10),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
          color: Color(0xff872CD8), borderRadius: BorderRadius.circular(18)),
    );
  }
}
