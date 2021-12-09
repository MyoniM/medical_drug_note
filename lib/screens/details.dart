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
  int? _cllr;

  var _data = "";

  setX(y) {
    _cllr = y;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class details"),
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
                  clr: _cllr ?? d!.clr,
                ),
              );

              if (count > 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Class updated successfully.')));
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
                    ColorPicker(drug.clr, setX),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Category id: "),
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
                                                padding: const EdgeInsets.only(
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
                          },
                        ),
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
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Delete class?'),
      content: const Text("Are you sure you want to delete this class?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogCtx).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red[600]),
          onPressed: () {
            Navigator.of(dialogCtx).pop(true);
          },
          child: const Text('DELETE'),
        ),
      ],
    ),
  ).then(
    (value) async {
      if (value == true) {
        final count = await DrugDb.instance.delete(drugId);
        if (count == 1) {
          Navigator.of(context).pop(true);
        } else if (count == -100) {
          Navigator.of(context).pop("true");
        } else {
          Navigator.of(context).pop(false);
        }
      }
    },
  );
}

class ColorPicker extends StatefulWidget {
  const ColorPicker(
    this.clr,
    this.onC, {
    Key? key,
  }) : super(key: key);

  final int clr;
  final Function onC;
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int? _value;
  onChange(value) {
    widget.onC(value);
    setState(() {
      _value = value;
    });
  }

  @override
  void initState() {
    _value = widget.clr;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        clr(Colors.black, Colors.black.value, _value!, onChange),
        clr(Colors.orange, Colors.orange.value, _value!, onChange),
        clr(Colors.green, Colors.green.value, _value!, onChange),
        clr(Colors.blue, Colors.blue.value, _value!, onChange),
        clr(Colors.red, Colors.red.value, _value!, onChange),
      ],
    );
  }
}

class clr extends StatefulWidget {
  clr(this.color, this.value, this.groupValue, this.onChanged, {Key? key});
  final Color color;
  final int value;
  final int groupValue;
  final Function onChanged;

  @override
  State<clr> createState() => _clrState();
}

class _clrState extends State<clr> {
  @override
  Widget build(BuildContext context) {
    bool _selected = widget.value == widget.groupValue;
    return InkWell(
      onTap: () => widget.onChanged(widget.value),
      child: Container(
        width: MediaQuery.of(context).size.width * .17,
        height: 30,
        child: _selected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              )
            : null,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
