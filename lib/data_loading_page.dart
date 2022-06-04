import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mods_loader.dart';

class DataLoadingPage extends StatefulWidget {
  const DataLoadingPage({Key? key}) : super(key: key);

  @override
  _DataLoadingPageState createState() => _DataLoadingPageState();
}

class _DataLoadingPageState extends State<DataLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: modsLoader(),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              allModFiles = snapshot.data;
              cateList = categories(allModFiles);
              //print('${allModFiles.length} iceFiles Loaded');

              return const HomePage();
            }
          }
        });
  }
}
