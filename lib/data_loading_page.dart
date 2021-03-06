import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Error when loading data. Reload the app.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyText1?.color, fontSize: 20),
                  ),
                ],
              );
            } else if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              allModFiles = snapshot.data;
              cateList = categories(allModFiles);
              appliedModsListGet = getAppliedModsList();
              iceFiles = dataDir.listSync(recursive: true).whereType<File>().toList();
              Provider.of<stateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);
              //print('${allModFiles.length} iceFiles Loaded');

              return const HomePage();
            }
          }
        });
  }
}
