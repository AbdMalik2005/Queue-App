import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void showQueueInfo(BuildContext context, String Queue_code) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Color(0xffF8F5FF), // لون خلفية ناعم
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xff872CD8), width: 2),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: barcode_widget.BarcodeWidget(
                width: 200,
                height: 200,
                color: Color(0xff872CD8),
                data: Queue_code,
                barcode: barcode_widget.Barcode.qrCode(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Queue_code,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: "Myfont",
                color: Color(0xff872CD8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff872CD8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Exit",
              style: TextStyle(
                fontFamily: "Myfont",
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    },
  );
}
