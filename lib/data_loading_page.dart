import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

class DataLoadingPage extends StatefulWidget {
  const DataLoadingPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Loading Data',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                CircularProgressIndicator(),
              ],
            );
          } else {
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curLangText!.errorLoadingRestartApp,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                  ),
                ],
              );
            } else if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Loading Data',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            } else {
              allModFiles = snapshot.data;
              cateList = categories(allModFiles);
              // Sort cate list
              if (selectedSortType == 1) {
                cateList.sort(((a, b) => b.numOfItems.compareTo(a.numOfItems)));
                ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                cateList.insert(0, favCate);
                selectedSortTypeString = curLangText!.sortCateByNumItemsText;
              } else if (selectedSortType == 0) {
                cateList.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
                ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                cateList.insert(0, favCate);
              }
              appliedModsListGet = getAppliedModsList();
              modSetsListGet = getSetsList();
              iceFiles = dataDir.listSync(recursive: true).whereType<File>().toList();
              Provider.of<StateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);

              return const HomePage();
            }
          }
        });
  }
}