import 'package:flutter/material.dart';

import 'package:nest/db/db.dart';
import '../models/drug_container.dart';

class MainDrugs extends StatefulWidget {
  const MainDrugs({Key? key}) : super(key: key);
  static const routeName = "/mainDrugs";

  @override
  _MainDrugsState createState() => _MainDrugsState();
}

class _MainDrugsState extends State<MainDrugs> {
  @override
  void dispose() {
    // TODO: implement dispose
    // DrugDb.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("==========================================");
    var mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("DRUG CATEGORIES"),
      ),
      body: SafeArea(
        child: FutureBuilder<List<DrugContainer>>(
            future: DrugDb.instance.readAllDrugContainers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      data!.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var dt = DateTime.parse(
                                      data[index].createdAt.toString());
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed("/tree",
                                              arguments: (data[index]))
                                          .then((value) {
                                        if (value == true) {
                                          setState(() {});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Success.'),
                                            ),
                                          );
                                        } else if (value == false) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Something went wrong.'),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: ListTile(
                                        horizontalTitleGap: -15,
                                        // leading: Text((index + 1).toString()),
                                        title: Text(
                                          data[index].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                                "${dt.year}/${dt.month}/${dt.day}"),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              child: Text(
                                                  " ${dt.hour}:${dt.minute}"),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text("ADD DRUG CATEGORY"),
        onPressed: () {
          _show(context);
        },
      ),
    );
  }
}

void _show(context) {
  var _data = "";
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Add category'),
      content: TextFormField(
        onChanged: (val) {
          _data = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogCtx).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(dialogCtx).pop(true);
          },
          child: const Text('ADD'),
        ),
      ],
    ),
  ).then(
    (value) => {
      if (value)
        {
          if (_data == "" || _data.isEmpty)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category name is neccessary!'),
              ),
            )
          else
            DrugDb.instance.createDrugContainer(
              DrugContainer(
                name: _data,
                createdAt: DateTime.now().toIso8601String(),
              ),
            )
        },
    },
  );
}
