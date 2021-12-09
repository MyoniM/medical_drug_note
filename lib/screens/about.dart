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
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: .5),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Use this to share data with another user",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () async {
                        await pickFiles(fileType);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade400,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text("SELECT FILE TO IMPORT"),
                    ),
                    if (file != null) fileDetails(file!),
                    if (file != null) importFile(file!),
                    ElevatedButton(
                      onPressed: () {
                        DrugHelper.exportData().then((value) {
                          if (value == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'nested_data.json file exported to downloads folder.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Something went wrong. Check app permissions.')));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40)),
                      child: const Text("EXPORT DATA"),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: .5),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: const Text(
                        "If error persists, deny the app's storage permission and allow it again.",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("@Disclaimer, Use at Your Own Risk"),
              const SizedBox(height: 5),
              const Text(
                  "The developer, in any way whatsoever, will not be responsible for your use of the app and any problems that may arise when using it. Double check the stored values before using/sharing."),
              const SizedBox(height: 20),
              const Text("Meet the developer, Yonatan"),
              const SizedBox(height: 5),
              const Text("Telegram: @Y00NII"),
              const Text("Email: se.yonatan.merkebu@gmail.com"),
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
              backgroundColor: Colors.grey[300], primary: Colors.red),
          onPressed: () async {
            DrugHelper.importData(file).then((value) {
              if (value == 1) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Successfully imported data from nested_data.json.')));
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
