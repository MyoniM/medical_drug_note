import 'package:flutter/material.dart';
import 'package:nest/db/db.dart';

import 'package:nest/router.dart';
import 'package:nest/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // TODO: implement dispose
    DrugDb.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData().copyWith(
        primaryColor: Colors.grey.shade800,
        hoverColor: Colors.red.shade100,
        colorScheme:
            ThemeData().colorScheme.copyWith(primary: Colors.grey.shade800),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
      onGenerateRoute: AppRouter().onGenerateRoute,
    );
  }
}

// !!!!!!!!!
// ! node arrow to right
// !!!
// ! color