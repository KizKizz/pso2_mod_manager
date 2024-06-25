import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_injection_page.dart';
import 'package:pso2_mod_manager/classes/aqm_item_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController injectedItemsSearchTextController = TextEditingController();
TextEditingController availableItemsSearchTextController = TextEditingController();
String fromItemIconLink = '';
String toItemIconLink = '';
Future allAqmItemList = basewearsListGet();

class AqmInjectionHomePage extends StatefulWidget {
  const AqmInjectionHomePage({super.key});

  @override
  State<AqmInjectionHomePage> createState() => _AqmInjectionHomePageState();
}

class _AqmInjectionHomePageState extends State<AqmInjectionHomePage> {
  @override
  void initState() {
    //clear
    if (Directory(modManSwapperFromItemDirPath).existsSync()) {
      Directory(modManSwapperFromItemDirPath).deleteSync(recursive: true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CsvItem> csvItems = playerItemData
        .where((e) =>
            e.category == defaultCategoryDirs[1] &&
            e.infos.entries.firstWhere((i) => i.key == 'High Quality').value.isNotEmpty &&
            e.infos.entries.firstWhere((i) => i.key == 'Normal Quality').value.isNotEmpty)
        .toList();
    List<AqmItem> aqmItems = [];
    List<ModFile> allAppliedModFiles = [];
    for (var cateType in moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0)) {
      for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
        for (var item in cate.items) {
          if (item.applyStatus) {
            for (var mod in item.mods) {
              if (mod.applyStatus) {
                for (var submod in mod.submods) {
                  if (submod.applyStatus) {
                    for (var modFile in submod.modFiles) {
                      if (modFile.applyStatus) {
                        allAppliedModFiles.add(modFile);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder(
              future: allAqmItemList,
              builder: (
                BuildContext context,
                AsyncSnapshot snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          curLangText!.uiLoadingPlayerItemData,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            curLangText!.uiError,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            curLangText!.uiLoadingPlayerItemData,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const CircularProgressIndicator(),
                        ],
                      ),
                    );
                  } else {
                    //displayList
                    aqmItems = snapshot.data;

                    //available Items
                    List<CsvItem> availableItem = [];
                    if (availableItemsSearchTextController.text.isEmpty) {
                      availableItem = csvItems;
                    } else {
                      availableItem = csvItems
                          .where((e) =>
                              e.getENName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()) ||
                              e.getJPName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()))
                          .toList();
                    }
                    //injected Items
                    List<AqmItem> injectedItem = [];
                    if (injectedItemsSearchTextController.text.isEmpty) {
                      injectedItem = aqmItems;
                    } else {
                      injectedItem = aqmItems
                          .where((e) =>
                              e.itemNameEN.toLowerCase().contains(injectedItemsSearchTextController.text.toLowerCase()) ||
                              e.itemNameJP.toLowerCase().contains(injectedItemsSearchTextController.text.toLowerCase()))
                          .toList();
                    }

                    return Row(
                      children: [
                        RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'AQM INJECTION',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 20),
                            )),
                        VerticalDivider(
                          width: 10,
                          thickness: 2,
                          indent: 5,
                          endIndent: 5,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //left
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                          child: SizedBox(
                                            height: 92,
                                            child: ListTile(
                                              minVerticalPadding: 15,
                                              title: Text(curLangText!.uiItemsToInjectCustomAqm),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: SizedBox(
                                                  height: 30,
                                                  width: double.infinity,
                                                  child: TextField(
                                                    controller: availableItemsSearchTextController,
                                                    maxLines: 1,
                                                    textAlignVertical: TextAlignVertical.center,
                                                    decoration: InputDecoration(
                                                        hintText: curLangText!.uiSearchSwapItems,
                                                        hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                                        isCollapsed: true,
                                                        isDense: true,
                                                        contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                                                        suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                                                        suffixIcon: InkWell(
                                                          onTap: availableItemsSearchTextController.text.isEmpty
                                                              ? null
                                                              : () {
                                                                  availableItemsSearchTextController.clear();
                                                                  setState(() {});
                                                                },
                                                          child: Icon(
                                                            availableItemsSearchTextController.text.isEmpty ? Icons.search : Icons.close,
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                        constraints: BoxConstraints.tight(const Size.fromHeight(26)),
                                                        // Set border for enabled state (default)
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        // Set border for focused state
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                                                          borderRadius: BorderRadius.circular(10),
                                                        )),
                                                    onChanged: (value) async {
                                                      if (availableItemsSearchTextController.text.isEmpty) {
                                                        availableItem = csvItems;
                                                      } else {
                                                        availableItem = csvItems
                                                            .where((e) =>
                                                                e.getENName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()) ||
                                                                e.getJPName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()))
                                                            .toList();
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                  color:
                                                      MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                                  child: ScrollbarTheme(
                                                    data: ScrollbarThemeData(
                                                      thumbColor: WidgetStateProperty.resolveWith((states) {
                                                        if (states.contains(WidgetState.hovered)) {
                                                          return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                        }
                                                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                      }),
                                                    ),
                                                    child: ListView.builder(
                                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                        shrinkWrap: true,
                                                        //physics: const PageScrollPhysics(),
                                                        itemCount: availableItem.length,
                                                        itemBuilder: (context, i) {
                                                          return Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                                              child: ListTile(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                  //icon
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                                    child: Container(
                                                                        width: 80,
                                                                        height: 80,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(3),
                                                                          border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                                                        ),
                                                                        child: Image.network(
                                                                          '$modManMAIconDatabaseLink${availableItem[i].iconImagePath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
                                                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                            'assets/img/placeholdersquare.png',
                                                                            filterQuality: FilterQuality.none,
                                                                            fit: BoxFit.fitWidth,
                                                                          ),
                                                                          filterQuality: FilterQuality.none,
                                                                          fit: BoxFit.fitWidth,
                                                                        )),
                                                                  ),
                                                                  //names
                                                                  Padding(
                                                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          modManCurActiveItemNameLanguage == 'JP'
                                                                              ? Text(availableItem[i].getJPName().trim())
                                                                              : Text(availableItem[i].getENName().trim()),
                                                                          const SizedBox(height: 10),
                                                                          Text('Id: ${p.basenameWithoutExtension(availableItem[i].infos.entries.firstWhere((e) => e.key == 'Id').value)}',
                                                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                          Text('Id2: ${p.basenameWithoutExtension(availableItem[i].infos.entries.firstWhere((e) => e.key == 'Adjusted Id').value)}',
                                                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                          Text('HQ: ${p.basenameWithoutExtension(availableItem[i].infos.entries.firstWhere((e) => e.key == 'High Quality').value)}',
                                                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                          Text('LQ: ${p.basenameWithoutExtension(availableItem[i].infos.entries.firstWhere((e) => e.key == 'Normal Quality').value)}',
                                                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                        ],
                                                                      )),
                                                                ]),
                                                                subtitle: ElevatedButton(
                                                                    onPressed: aqmItems
                                                                                .where((element) =>
                                                                                    element.itemNameEN == availableItem[i].getENName() || element.itemNameJP == availableItem[i].getJPName())
                                                                                .isEmpty &&
                                                                            File(modManCustomAqmFilePath).existsSync() &&
                                                                            allAppliedModFiles
                                                                                .where((e) => e.modFileName == availableItem[i].infos.entries.firstWhere((e) => e.key == 'High Quality').value)
                                                                                .isEmpty &&
                                                                            allAppliedModFiles
                                                                                .where((e) => e.modFileName == availableItem[i].infos.entries.firstWhere((e) => e.key == 'Normal Quality').value)
                                                                                .isEmpty
                                                                        ? () async {
                                                                            final hqIcePaths = fetchOriginalIcePaths(availableItem[i].infos.entries.firstWhere((e) => e.key == 'High Quality').value);
                                                                            final lqIcePaths = fetchOriginalIcePaths(availableItem[i].infos.entries.firstWhere((e) => e.key == 'Normal Quality').value);
                                                                            final iconIcePaths = fetchOriginalIcePaths(availableItem[i].infos.entries.firstWhere((e) => e.key == 'Icon').value);
                                                                            AqmItem newItem = AqmItem(
                                                                                availableItem[i].category,
                                                                                availableItem[i].infos.entries.firstWhere((e) => e.key == 'Id').value,
                                                                                availableItem[i].infos.entries.firstWhere((e) => e.key == 'Adjusted Id').value,
                                                                                availableItem[i].iconImagePath,
                                                                                availableItem[i].getENName(),
                                                                                availableItem[i].getJPName(),
                                                                                hqIcePaths.isNotEmpty ? hqIcePaths.first : '',
                                                                                lqIcePaths.isNotEmpty ? lqIcePaths.first : '',
                                                                                iconIcePaths.isNotEmpty ? iconIcePaths.first : '',
                                                                                false,
                                                                                false);
                                                                            bool value = await itemAqmInjectionHomePage(context, newItem.hqIcePath, newItem.lqIcePath);
                                                                            if (value) {
                                                                              newItem.isApplied = true;
                                                                              aqmItems.add(newItem);
                                                                              //Save to json
                                                                              aqmItems.map((item) => item.toJson()).toList();
                                                                              const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                                                              File(modManAqmInjectedItemListJsonPath).writeAsStringSync(encoder.convert(aqmItems));
                                                                            }

                                                                            setState(() {});
                                                                          }
                                                                        : null,
                                                                    child: Text(curLangText!.uiInjectCustomAqmIntoThisItem)),
                                                              ));
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ],
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

                                    //right
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                          child: SizedBox(
                                              height: 92,
                                              child: ListTile(
                                                minVerticalPadding: 15,
                                                title: Text(curLangText!.uiItemsAlreadyHaveCustomAqm),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: SizedBox(
                                                    height: 30,
                                                    width: double.infinity,
                                                    child: TextField(
                                                      controller: injectedItemsSearchTextController,
                                                      maxLines: 1,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                          hintText: curLangText!.uiSearchSwapItems,
                                                          hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                                          isCollapsed: true,
                                                          isDense: true,
                                                          contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                                                          suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                                                          suffixIcon: InkWell(
                                                            onTap: injectedItemsSearchTextController.text.isEmpty
                                                                ? null
                                                                : () {
                                                                    injectedItemsSearchTextController.clear();
                                                                    setState(() {});
                                                                  },
                                                            child: Icon(
                                                              injectedItemsSearchTextController.text.isEmpty ? Icons.search : Icons.close,
                                                              color: Theme.of(context).hintColor,
                                                            ),
                                                          ),
                                                          constraints: BoxConstraints.tight(const Size.fromHeight(26)),
                                                          // Set border for enabled state (default)
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          // Set border for focused state
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                                                            borderRadius: BorderRadius.circular(10),
                                                          )),
                                                      onChanged: (value) async {
                                                        if (injectedItemsSearchTextController.text.isEmpty) {
                                                          injectedItem = aqmItems;
                                                        } else {
                                                          injectedItem = aqmItems
                                                              .where((e) =>
                                                                  e.itemNameEN.toLowerCase().contains(injectedItemsSearchTextController.text.toLowerCase()) ||
                                                                  e.itemNameJP.toLowerCase().contains(injectedItemsSearchTextController.text.toLowerCase()))
                                                              .toList();
                                                        }
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ),
                                        const Divider(
                                          height: 5,
                                          thickness: 1,
                                          indent: 5,
                                          endIndent: 5,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                    color: MyApp.themeNotifier.value == ThemeMode.light
                                                        ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7)
                                                        : Colors.transparent,
                                                    child: ScrollbarTheme(
                                                        data: ScrollbarThemeData(
                                                          thumbColor: WidgetStateProperty.resolveWith((states) {
                                                            if (states.contains(WidgetState.hovered)) {
                                                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                            }
                                                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                          }),
                                                        ),
                                                        child: ListView.builder(
                                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                            shrinkWrap: true,
                                                            //physics: const BouncingScrollPhysics(),
                                                            itemCount: injectedItem.length,
                                                            itemBuilder: (context, i) {
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                                child: ListTile(
                                                                  shape: RoundedRectangleBorder(
                                                                      side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                  title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                    //icon
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                                      child: Container(
                                                                          width: 80,
                                                                          height: 80,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(3),
                                                                            border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                                                          ),
                                                                          child: Image.network(
                                                                            '$modManMAIconDatabaseLink${injectedItem[i].iconImagePath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
                                                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                              'assets/img/placeholdersquare.png',
                                                                              filterQuality: FilterQuality.none,
                                                                              fit: BoxFit.fitWidth,
                                                                            ),
                                                                            filterQuality: FilterQuality.none,
                                                                            fit: BoxFit.fitWidth,
                                                                          )),
                                                                    ),
                                                                    //names
                                                                    Padding(
                                                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            modManCurActiveItemNameLanguage == 'JP' ? Text(injectedItem[i].itemNameJP.trim()) : Text(injectedItem[i].itemNameEN.trim()),
                                                                            const SizedBox(height: 10),
                                                                            Text('Id: ${p.basenameWithoutExtension(injectedItem[i].id)}',
                                                                                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                            Text('Id2: ${p.basenameWithoutExtension(injectedItem[i].adjustedId)}',
                                                                                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                            Text('HQ: ${p.basenameWithoutExtension(injectedItem[i].hqIcePath)}',
                                                                                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                            Text('LQ: ${p.basenameWithoutExtension(injectedItem[i].lqIcePath)}',
                                                                                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                          ],
                                                                        )),
                                                                  ]),
                                                                  subtitle: ElevatedButton(
                                                                      onPressed: () async {
                                                                        List<String> restorePaths = [];
                                                                        if (injectedItem[i].hqIcePath.isNotEmpty) {
                                                                          restorePaths.add(injectedItem[i].hqIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim());
                                                                        }
                                                                        if (injectedItem[i].lqIcePath.isNotEmpty) {
                                                                          restorePaths.add(injectedItem[i].hqIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim());
                                                                        }
                                                                        if (restorePaths.isNotEmpty) {
                                                                          await downloadIceFromOfficial(restorePaths);
                                                                          aqmItems.remove(injectedItem[i]);
                                                                        }
                                                                        //Save to json
                                                                        aqmItems.map((item) => item.toJson()).toList();
                                                                        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                                                        File(modManAqmInjectedItemListJsonPath).writeAsStringSync(encoder.convert(aqmItems));

                                                                        setState(() {});
                                                                      },
                                                                      child: Text(curLangText!.uiRemoveCustomAqmFromThisItem)),
                                                                ),
                                                              );
                                                            }))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(curLangText!.uiNoteMustSelectACustomAqmFileBeforeInject),
                                    Wrap(
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      spacing: 5,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              const XTypeGroup typeGroup = XTypeGroup(
                                                label: '.aqm',
                                                extensions: <String>['aqm'],
                                              );
                                              final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                              if (selectedFile != null) {
                                                modManCustomAqmFileName = selectedFile.name;
                                                prefs.setString('modManCustomAqmFileName', modManCustomAqmFileName);
                                                if (Directory(modManCustomAqmDir).existsSync() && modManCustomAqmFileName.isNotEmpty) {
                                                  modManCustomAqmFilePath = Uri.file('$modManCustomAqmDir/$modManCustomAqmFileName').toFilePath();
                                                  File(selectedFile.path).copySync(modManCustomAqmFilePath);
                                                }
                                              }
                                              setState(() {});
                                            },
                                            child: Text(!File(modManCustomAqmFilePath).existsSync() ? curLangText!.uiSelectAqmFile : curLangText!.uiReSelectAqmFile,
                                                style: const TextStyle(fontWeight: FontWeight.w400))),
                                        ElevatedButton(
                                            onPressed: () {
                                              injectedItemsSearchTextController.clear();
                                              availableItemsSearchTextController.clear();
                                              Navigator.pop(context);
                                            },
                                            child: Text(curLangText!.uiClose)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }
                }
              });
        }));
  }
}

Future<List<AqmItem>> basewearsListGet() async {
  List<AqmItem> structureFromJson = [];

  //Load list from json
  String dataFromJson = await File(modManAqmInjectedItemListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      structureFromJson.add(AqmItem.fromJson(item));
    }
  }

  return structureFromJson;
}
