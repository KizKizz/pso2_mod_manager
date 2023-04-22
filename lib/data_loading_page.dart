import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages

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
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                  )
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
              if (checkSumFilePath != null && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match && localChecksumMD5 != null && win32ChecksumMD5 != null) {
                if (win32ChecksumMD5 != localChecksumMD5 || !File(win32CheckSumFilePath).existsSync()) {
                  File(checkSumFilePath.toString()).copySync(win32CheckSumFilePath);
                }
              }
              allModFiles = snapshot.data;
              cateList = categories(allModFiles);
              appliedModsListGet = getAppliedModsList();
              modSetsListGet = getSetsList();

              Provider.of<StateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);

              return const HomePage();
            }
          }
        });
  }
}
