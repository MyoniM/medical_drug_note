import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nest/db/db.dart';

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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
        actions: [
          PopupMenuButton(
            onSelected: (val) {
              if (val == 1) {}
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text("About"),
                value: 1,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FloatingSearchBar(
                  hint: 'Search drug...',
                  elevation: 2.0,
                  margins: const EdgeInsets.all(0),
                  backdropColor: Colors.transparent,
                  width: double.infinity,
                  transition: CircularFloatingSearchBarTransition(),
                  openAxisAlignment: 0.0,
                  debounceDelay: const Duration(milliseconds: 500),
                  onQueryChanged: (query) {
                    // Call your model, bloc, controller here.
                  },
                  builder: (context, transition) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: Colors.white,
                        elevation: 2.0,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: const Center(
                                child: Text(
                                  "No recent searches",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          ],
                          // mainAxisSize: MainAxisSize.min,
                          // children: Colors.accents.map((color) {
                          //   return Container(height: 112, color: color);
                          // }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              FutureBuilder<List<int>>(
                future: Future.wait([
                  DrugDb.instance.getDrugCount(),
                  DrugDb.instance.getCategoryCount(),
                ]),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return Row(
                      children: [
                        Expanded(child: Stat(mq, "Categories", data[1])),
                        Expanded(child: Stat(mq, "Drugs", data[0])),
                      ],
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/mainDrugs").then((value) {
                    setState(() {});
                  });
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

  Widget Stat(Size mq, String title, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      height: mq.height * .15,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400, width: .5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Total $title",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(height: 15),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 35),
          ),
        ],
      ),
    );
  }
}
