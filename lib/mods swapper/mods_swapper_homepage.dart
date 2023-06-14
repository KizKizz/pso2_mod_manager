import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_popup.dart';

class ModsSwapperHomePage extends StatefulWidget {
  const ModsSwapperHomePage({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperHomePage> createState() => _ModsSwapperHomePageState();
}

class _ModsSwapperHomePageState extends State<ModsSwapperHomePage> {
  @override
  Widget build(BuildContext context) {
    //create temp dirs
    Directory(modManSwapperDirPath).createSync(recursive: true);
    Directory(modManSwapperIconsDirPath).createSync(recursive: true);

    //fetch icons
    final iceNamesFromSubmod = widget.fromSubmod.getModFileNames();
    final fromItemCsvData = csvData
        .where((element) =>
            iceNamesFromSubmod.contains(element.hqIceName) ||
            iceNamesFromSubmod.contains(element.nqIceName) ||
            iceNamesFromSubmod.contains(element.nqLiIceName) ||
            iceNamesFromSubmod.contains(element.hqLiIceName))
        .toList();
    List<List<String>> csvInfos = [];
    for (var csvItemData in fromItemCsvData) {
      final data = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
      final availableModFileData = data.where((element) => iceNamesFromSubmod.contains(element.split(': ').last)).toList();
      csvInfos.add(availableModFileData);
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'MODS SWAP',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 12),
                  )),
              VerticalDivider(
                width: 10,
                thickness: 2,
                indent: 5,
                endIndent: 5,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              //from
              Expanded(
                  child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                    color: Colors.transparent,
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                ),
                                child: widget.fromItem.icons.first.contains('assets/img/placeholdersquare.png')
                                    ? Image.asset(
                                        'assets/img/placeholdersquare.png',
                                        filterQuality: FilterQuality.none,
                                        fit: BoxFit.fitWidth,
                                      )
                                    : Image.file(
                                        File(widget.fromItem.icons.first),
                                        filterQuality: FilterQuality.none,
                                        fit: BoxFit.fitWidth,
                                      )),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.fromItem.category,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Text(widget.fromItem.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text('${widget.fromSubmod.modName} > ${widget.fromSubmod.submodName}')
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 5,
                    thickness: 1,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                      color: Colors.transparent,
                      child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                              }
                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                            }),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Item variant found in current mod files'),
                            ),
                            ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                  }
                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                }),
                              ),
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                  shrinkWrap: true,
                                  //physics: const NeverScrollableScrollPhysics(),
                                  itemCount: fromItemCsvData.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: RadioListTile(
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        value: fromItemCsvData[i],
                                        groupValue: selectedFromCsvFile,
                                        title: Text(fromItemCsvData[i].enName),
                                        subtitle: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [for (int line = 0; line < csvInfos[i].length; line++) Text(csvInfos[i][line])],
                                        ),
                                        onChanged: (CsvIceFile? currentItem) {
                                          //print("Current ${moddedItemsList[i].groupName}");
                                          selectedFromCsvFile = currentItem!;
                                          setState(
                                            () {},
                                          );
                                        },
                                      ),
                                    );
                                  }),
                            )
                          ])),
                    ),
                  ),
                ],
              )),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 25,
                ),
              ),
              //to
              Expanded(
                  child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                    color: Colors.transparent,
                    child: const SizedBox(
                        height: 90,
                        child: ListTile(
                          title: Text('Choose an item below to swap'),
                        )),
                  ),
                  const Divider(
                    height: 5,
                    thickness: 1,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Expanded(
                    child: Card(
                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                        color: Colors.transparent,
                        child: ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                }
                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                              }),
                            ),
                            child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                shrinkWrap: true,
                                //physics: const NeverScrollableScrollPhysics(),
                                itemCount: availableItemsCsvData.length,
                                itemBuilder: (context, i) {
                                  return RadioListTile(
                                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                    value: availableItemsCsvData[i],
                                    groupValue: selectedToCsvFile,
                                    title: Text(availableItemsCsvData[i].enName),
                                    onChanged: (CsvIceFile? currentItem) {
                                      //print("Current ${moddedItemsList[i].groupName}");
                                      selectedToCsvFile = currentItem!;
                                      setState(
                                        () {},
                                      );
                                    },
                                  );
                                }))),
                  ),
                ],
              ))
            ],
          );
        }));
  }
}
