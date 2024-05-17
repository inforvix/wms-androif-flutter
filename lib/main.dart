// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:wms_android/views/login_page.dart';
import 'package:wms_android/views/movimentacao/items_movimentacao_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    ToastContext().init(context);
    return MaterialApp(
      title: 'WMS - Inforvix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleSmall: TextStyle(
                fontSize: 14,
                fontFamily: 'Releway',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                fontSize: 16,
                fontFamily: 'Releway',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontFamily: 'Releway',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      home: LoginPage(),
    );
  }
}
