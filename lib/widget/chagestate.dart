import 'package:flutter/material.dart';

class ChangeStateuser extends StatefulWidget {
  String selectedstate;
  final Function(String) onStateChanged;
  
  ChangeStateuser({
    super.key, 
    required this.selectedstate,
    required this.onStateChanged,
  });

  @override
  State<ChangeStateuser> createState() => _ChangeStateuserState();
}

class _ChangeStateuserState extends State<ChangeStateuser> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.selectedstate = 'Client';
              widget.onStateChanged('Client');
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: widget.selectedstate == 'Client'
                  ? const Color(0xff872CD8)
                  : const Color(0xffD9D9D9),
            ),
            child: Text(
              'Client',
              style: TextStyle(
                fontFamily: "Myfont",
                fontSize: 16,
                color: widget.selectedstate == 'Client' ? Colors.white : Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.selectedstate = 'Employee';
              widget.onStateChanged('Employee');
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: widget.selectedstate == 'Employee'
                  ? const Color(0xff872CD8)
                  : const Color(0xffD9D9D9),
            ),
            child: Text(
              'Employee',
              style: TextStyle(
                fontFamily: "Myfont",
                fontSize: 16,
                color: widget.selectedstate == 'Employee' ? Colors.white : Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
