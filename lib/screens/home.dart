import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const routeName = "/home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/mainDrugs");
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                child: const Text("READ/ EDIT DATA"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
