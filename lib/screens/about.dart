import 'package:flutter/material.dart';
import 'package:nest/helpers/drug_helper.dart';
import 'package:file_picker/file_picker.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);
  static const routeName = "/about";

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String fileType = 'All';

  PlatformFile? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await pickFiles(fileType);
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                child: const Text("SELECT FILE TO IMPORT"),
              ),
              if (file != null) fileDetails(file!),
              if (file != null) importFile(file!),
              ElevatedButton(
                onPressed: () {
                  DrugHelper.exportData().then((value) {
                    if (value == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'medical_drugs.json file exported to downloads folder.')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Something went wrong.')));
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40)),
                child: const Text("EXPORT DATA"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fileDetails(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File Name: ${file.name}'),
          Text('File Size: $size'),
          Text('File Extension: ${file.extension}'),
          // Text('File Path: ${file.path}'),
        ],
      ),
    );
  }

  Widget importFile(PlatformFile file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade200, width: .5),
            borderRadius: BorderRadius.circular(5),
            color: Colors.red[50],
          ),
          child: const Text(
            "Importing from external file will override all of your existing data!",
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
          onPressed: () async {
            DrugHelper.importData(file).then((value) {
              if (value == 1) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Successfully imported data from medical_drugs.json.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong.')));
              }
            });
          },
          child: const Text("IMPORT ANYWAYS"),
        )
      ],
    );
  }

  Future<void> pickFiles(String? filetype) async {
    switch (filetype) {
      case 'All':
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result == null) return;
        file = result.files.first;
        setState(() {});
        break;
    }
  }
}
