import 'package:flutter/material.dart';
import 'package:nest/db/db.dart';
import 'package:nest/helpers/drug_helper.dart';
import 'package:nest/models/drug.dart';

class Details extends StatelessWidget {
  final int drugId;
  Details({Key? key, required this.drugId}) : super(key: key);
  static const routeName = "/details";

  Drug? d;
  String? _drugName;
  String? _drugDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drug details"),
        actions: [
          IconButton(
            onPressed: () async {
              final count = await DrugDb.instance.update(
                Drug(
                  id: d!.id,
                  name: (_drugName != null && _drugName != "")
                      ? _drugName!
                      : d!.name,
                  description: _drugDescription ?? d!.description,
                  parentId: d!.parentId,
                  categoryId: d!.categoryId,
                  createdAt: d!.createdAt,
                ),
              );

              if (count > 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Drug updated successfully.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong.')));
              }
            },
            icon: const Icon(Icons.save_rounded),
          ),
          PopupMenuButton(
            onSelected: (val) {
              if (val == 1) {
                _showDelete(context, drugId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text("Delete"),
                value: 1,
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Drug?>(
        future: DrugDb.instance.read(drugId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final drug = snapshot.data;
            if (drug == null) {
              return const Center(
                child: Text("No data associated with this id."),
              );
            }
            d = drug;
            var dt = DateTime.parse(drug.createdAt);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey.shade200,
                        border:
                            Border.all(color: Colors.grey.shade400, width: .5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Name"),
                          TextFormField(
                            initialValue: drug.name,
                            onChanged: (val) {
                              _drugName = val;
                            },
                          ),
                          const SizedBox(height: 15),
                          const Text("Description"),
                          TextFormField(
                            maxLines: 4,
                            initialValue: drug.description,
                            onChanged: (val) {
                              _drugDescription = val;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Category: "),
                                Text(drug.categoryId.toString())
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Created at: "),
                                Row(
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
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<Map<String, dynamic>>>(
                            future: DrugHelper.createAnccestorData(drug),
                            builder: (_, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data;
                                return Column(
                                  children: data!.map((e) {
                                    return Card(
                                      elevation: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              e["categoryName"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            ...e["anccesstors"]
                                                .reversed
                                                .map((el) {
                                              return Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 5,
                                                    left: 10,
                                                  ),
                                                  child: Text("-- ${el.name}"));
                                            })
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

void _showDelete(context, drugId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete drug?'),
      content: const Text("All data below this drug will be lost!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red[600]),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('DELETE'),
        ),
      ],
    ),
  ).then(
    (value) async {
      if (value == true) {
        final count = await DrugDb.instance.delete(drugId);
        if (count > 0) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(false);
        }
      }
    },
  );
}
