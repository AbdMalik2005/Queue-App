import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_app/screens/provider/DeleteClient.dart';
import 'package:project_app/screens/provider/Myalert.dart';

class ClientInfoCard extends StatefulWidget {
  final String Client_State;
  final String Client_name;
  final String Client_User_ID;
  final String Client_ID;
  final int Client_Number;
  final String Queue_Id;
  final int Current_number;

  const ClientInfoCard({
    super.key,
    required this.Client_State,
    required this.Client_User_ID,
    required this.Client_Number,
    required this.Queue_Id,
    required this.Client_name,
    required this.Current_number,
    required this.Client_ID,
  });

  @override
  State<ClientInfoCard> createState() => _ClientInfoCardState();
}

class _ClientInfoCardState extends State<ClientInfoCard> {
  @override
  Widget build(BuildContext context) {
    Color Card_Color;

    if (widget.Client_Number == widget.Current_number) {
      if (widget.Client_State == 'Active')
        Card_Color = Color(0xff2CD87D);
      else
        Card_Color = Colors.red;
    } else {
      Card_Color = Color(0xff872CD8);
    }

    return Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(20),
        width: 344,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Card_Color,
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer : ${widget.Client_name}',
                style: TextStyle(fontFamily: "Myfont", color: Colors.white),
              ),
              Text(
                'Number : ${widget.Client_Number}',
                style: TextStyle(fontFamily: "Myfont", color: Colors.white),
              ),
            ],
          ),
          widget.Client_Number == widget.Current_number
              ? GestureDetector(
                  onTap: () {
                    widget.Client_State == 'Active'
                        ? Myalert(
                            context,
                            () async => DeleteClient(
                                widget.Queue_Id,
                                widget.Client_ID,
                                widget.Client_State,
                                widget.Client_User_ID),
                            "Are you sure about deleting this client?")
                        : DeleteClient(widget.Queue_Id, widget.Client_ID,
                            widget.Client_State, widget.Client_User_ID);
                  },
                  child: CircleAvatar(
                      child: widget.Client_State == 'Active'
                          ? SvgPicture.asset(
                              'assets/check-mark.svg',
                              height: 30,
                              color: Colors.green,
                            )
                          : SvgPicture.asset(
                              'assets/close.svg',
                              height: 25,
                              color: Colors.red,
                            )),
                )
              : SizedBox()
        ]));
  }
}
