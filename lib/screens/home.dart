import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nest/db/db.dart';
import 'package:nest/models/drug.dart';
import 'package:nest/screens/details.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const routeName = "/home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Drug>? mutableDrugs;
  List<Drug> shownDrugs = [];

  @override
  void initState() {
    // TODO: implement initState
    getDrugs();
    super.initState();
  }

  void getDrugs() {
    DrugDb.instance.readAllDrugs().then((value) {
      setState(() {
        mutableDrugs = value;
      });
    });
  }

  void filterSearch(String query) {
    if (query.isNotEmpty) {
      shownDrugs = [];
      var searchRes = mutableDrugs!
          .where((element) =>
              element.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();

      setState(() {
        shownDrugs.addAll(searchRes);
      });
    } else {
      setState(() {
        shownDrugs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: FloatingSearchBar(
        hint: 'Search a drug...',
        elevation: 2.0,
        margins: const EdgeInsets.all(10),
        // backdropColor: Colors.transparent,
        width: double.infinity,
        transition: CircularFloatingSearchBarTransition(),
        physics: const BouncingScrollPhysics(),
        openAxisAlignment: 0.0,
        debounceDelay: const Duration(milliseconds: 500),
        onQueryChanged: (query) {
          filterSearch(query);
        },
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Material(
              elevation: 2.0,
              child: Column(
                children: [
                  if (shownDrugs.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: const Center(
                        child: Text(
                          "No result",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (shownDrugs.isNotEmpty)
                    ...shownDrugs.map((e) => searchResult(e)).toList()
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          );
        },
        body: FloatingSearchBarScrollNotifier(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                      getDrugs();
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
      ),
    );
  }

  Widget Stat(Size mq, String title, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
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

  Widget searchResult(Drug drug) {
    var dt = DateTime.parse(drug.createdAt.toString());
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Details.routeName, arguments: drug.id)
              .then((value) {
            getDrugs();
          });
        },
        title: Text(
          drug.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          drug.description,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${dt.year}/${dt.month}/${dt.day}"),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(
                right: 4,
              ),
              child: Text(" ${dt.hour}:${dt.minute}"),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
