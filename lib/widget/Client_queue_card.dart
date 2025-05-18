import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_app/screens/provider/Myalert.dart';
import 'package:project_app/screens/provider/Outqueue.dart';

class ClientQueueCard extends StatelessWidget {
  final String Queue_ID;
  final String Queue_name;
  final int You_number;
  final String Queue_code;
  final int Queue_current_number;

  const ClientQueueCard({
    super.key,
    required this.Queue_ID,
    required this.Queue_name,
    required this.Queue_code,
    required this.Queue_current_number,
    required this.You_number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      padding: EdgeInsets.all(30),
      width: 347,
      decoration: BoxDecoration(
        color: Color(0xff872CD8),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  Queue_name,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontFamily: "Myfont",
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Myalert(context, () async {
                    await OutQueue(Queue_ID);
                  }, "Are you sure about removing the queue?");
                },
                child: SvgPicture.asset(
                  'assets/out.svg',
                  height: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(children: [
            Text(
            'Your Number :',
            style: TextStyle(
              fontSize: 35,
              color: Colors.white,
              fontFamily: "Myfont",
            ),
          ),
          SizedBox(height: 10),
          Text(
            You_number.toString(),
            style: TextStyle(
              fontSize: 90,
              color: Colors.white,
              fontFamily: "Myfont",
            ),
          ),
          ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (You_number - Queue_current_number).toString(),
                style: TextStyle(
                  fontSize: 100,
                  fontFamily: "Myfont",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "Left",
                style: TextStyle(
                  fontFamily: "Myfont",
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
