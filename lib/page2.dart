import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({Key? key, this.payload}) : super(key: key);
  final String? payload;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'opened on taping notification',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text(
          payload!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black.withAlpha(50),
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
