import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/cml/cml_file_list_layout.dart';
import 'package:pso2_mod_manager/cml/cml_item_list_layout.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

class MainCmlReplaceGrid extends StatefulWidget {
  const MainCmlReplaceGrid({super.key});

  @override
  State<MainCmlReplaceGrid> createState() => _MainCmlReplaceGridState();
}

class _MainCmlReplaceGridState extends State<MainCmlReplaceGrid> {
  double fadeInOpacity = 0;
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();
  Signal<File?> selectedCmlFile = Signal<File?>(null);
  List<Cml> displayingItems = [];
  Signal<List<File>> displayingCmlFiles = Signal<List<File>>([]);

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort item data
    displayingItems = masterCMLItemList;
    displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));
    displayingCmlFiles.value = Directory(modCustomCmlsDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.cml').toList();

    return AnimatedOpacity(
      opacity: fadeInOpacity,
      duration: const Duration(milliseconds: 100),
      child: Column(spacing: 5, children: [
        Expanded(
            child: Row(
          spacing: 5,
          children: [
            Expanded(
                child: CmlFileListLayout(
              cmlFileList: displayingCmlFiles,
              scrollController: rScrollController,
              selectedCmlFile: selectedCmlFile,
            )),
            Expanded(
                child: CmlItemListLayout(
              cmlItemList: displayingItems,
              scrollController: lScrollController,
              selectedCmlFile: selectedCmlFile,
            )),
          ],
        )),
      ]),
    );
  }
}
