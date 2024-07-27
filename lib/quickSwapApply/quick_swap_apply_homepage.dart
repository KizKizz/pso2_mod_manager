// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController selectedItemsSearchTextController = TextEditingController();
TextEditingController availableItemsSearchTextController = TextEditingController();
String fromItemIconLink = '';
String toItemIconLink = '';
bool isLoading = false;
bool isAllButtonPressed = false;
late Future allAqmItemList;

// ignore: must_be_immutable
class QuickSwapApplyHomePage extends StatefulWidget {
  QuickSwapApplyHomePage({super.key, this.category});

  String? category;

  @override
  State<QuickSwapApplyHomePage> createState() => _AqmInjectionHomePageState();
}

class _AqmInjectionHomePageState extends State<QuickSwapApplyHomePage> {
  @override
  void initState() {
    // //clear
    // if (Directory(modManAddModsTempDirPath).existsSync()) {
    //   Directory(modManAddModsTempDirPath).deleteSync(recursive: true);
    // }
    allAqmItemList = quickSwapApplyItemListGet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CsvItem> csvItems = playerItemData
        .where((e) =>
            (e.category == widget.category ||
                (widget.category == defaultCategoryDirs[16] && e.category == defaultCategoryDirs[1]) ||
                (widget.category == defaultCategoryDirs[2] && e.category == defaultCategoryDirs[11]) ||
                (widget.category == defaultCategoryDirs[11] && e.category == defaultCategoryDirs[2])) &&
            (e.infos.entries.firstWhere((i) => i.key == 'High Quality').value.isNotEmpty || e.infos.entries.firstWhere((i) => i.key == 'Normal Quality').value.isNotEmpty))
        .toList();
    List<CsvItem> quickSwapApplySelectedItems = [];

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
                    quickSwapApplySelectedItems = snapshot.data;

                    //available Items
                    List<CsvItem> availableItem = [];
                    if (availableItemsSearchTextController.text.isEmpty) {
                      availableItem = csvItems.where((e) => modManCurActiveItemNameLanguage == 'JP' ? e.getJPName().isNotEmpty : e.getENName().isNotEmpty).toList();
                    } else {
                      availableItem = csvItems
                          .where((e) =>
                              (modManCurActiveItemNameLanguage == 'JP' ? e.getJPName().isNotEmpty : e.getENName().isNotEmpty) &&
                              (e.getENName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()) ||
                                  e.getJPName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase())))
                          .toList();
                    }
                    //injected Items
                    // quickSwapApplySelectedItems.removeWhere((e) => allAppliedModFiles.where((i) => i.modFileName == p.basenameWithoutExtension(e.hqIcePath)).isNotEmpty || allAppliedModFiles.where((i) => i.modFileName == p.basenameWithoutExtension(e.lqIcePath)).isNotEmpty);
                    //Save to json
                    quickSwapApplySelectedItems.map((item) => item.toJson()).toList();
                    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                    File(modManQuickSwapApplyItemsJsonPath).writeAsStringSync(encoder.convert(quickSwapApplySelectedItems));

                    if (selectedItemsSearchTextController.text.isEmpty) {
                      quickApplyItemList = quickSwapApplySelectedItems;
                    } else {
                      quickApplyItemList = quickSwapApplySelectedItems
                          .where((e) =>
                              e.getENName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()) ||
                              e.getJPName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()))
                          .toList();
                    }

                    return Row(
                      children: [
                        RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'QUICK SWAP-APPLY ITEMS',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 40),
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
                                              title: Text(curLangText!.uiAvailableItems),
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
                                                                          Text(
                                                                              availableItem[i].getENName().contains('[Se]')
                                                                                  ? '${curLangText!.uiCategory}: ${defaultCategoryNames[16]}'
                                                                                  : '${curLangText!.uiCategory}: ${defaultCategoryNames[availableItem[i].categoryIndex]}',
                                                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                        ],
                                                                      )),
                                                                ]),
                                                                subtitle: ElevatedButton(
                                                                    onPressed: quickApplyItemList
                                                                            .where((e) => e.getENName() == availableItem[i].getENName() || e.getJPName() == availableItem[i].getJPName())
                                                                            .isEmpty
                                                                        ? () async {
                                                                            quickApplyItemList.add(availableItem[i]);
                                                                            //Save to json
                                                                            quickSwapApplySelectedItems.map((item) => item.toJson()).toList();
                                                                            const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                                                            File(modManQuickSwapApplyItemsJsonPath).writeAsStringSync(encoder.convert(quickSwapApplySelectedItems));
                                                                            setState(() {});
                                                                          }
                                                                        : null,
                                                                    child: Text(curLangText!.uiAddToQuickApplyList)),
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
                                                title: Text(curLangText!.uiItemsInQuickApplyList),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: SizedBox(
                                                    height: 30,
                                                    width: double.infinity,
                                                    child: TextField(
                                                      controller: selectedItemsSearchTextController,
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
                                                            onTap: selectedItemsSearchTextController.text.isEmpty
                                                                ? null
                                                                : () {
                                                                    selectedItemsSearchTextController.clear();
                                                                    setState(() {});
                                                                  },
                                                            child: Icon(
                                                              selectedItemsSearchTextController.text.isEmpty ? Icons.search : Icons.close,
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
                                                        if (selectedItemsSearchTextController.text.isEmpty) {
                                                          quickApplyItemList = quickSwapApplySelectedItems;
                                                        } else {
                                                          quickApplyItemList = quickSwapApplySelectedItems
                                                              .where((e) =>
                                                                  e.getENName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()) ||
                                                                  e.getJPName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()))
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
                                                            itemCount: quickApplyItemList.length,
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
                                                                            '$modManMAIconDatabaseLink${quickApplyItemList[i].iconImagePath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
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
                                                                                ? Text(quickApplyItemList[i].getJPName().trim())
                                                                                : Text(quickApplyItemList[i].getENName().trim()),
                                                                            const SizedBox(height: 10),
                                                                            Text(
                                                                                availableItem[i].getENName().contains('[Se]')
                                                                                    ? '${curLangText!.uiCategory}: ${defaultCategoryNames[16]}'
                                                                                    : '${curLangText!.uiCategory}: ${defaultCategoryNames[quickApplyItemList[i].categoryIndex]}',
                                                                                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                          ],
                                                                        )),
                                                                  ]),
                                                                  subtitle: ElevatedButton(
                                                                      onPressed: !isAllButtonPressed
                                                                          ? () async {
                                                                              setState(() {
                                                                                isLoading = true;
                                                                                isAllButtonPressed = true;
                                                                              });
                                                                              quickApplyItemList.removeAt(i);
                                                                              //Save to json
                                                                              quickSwapApplySelectedItems.map((item) => item.toJson()).toList();
                                                                              const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                                                              File(modManQuickSwapApplyItemsJsonPath).writeAsStringSync(encoder.convert(quickSwapApplySelectedItems));

                                                                              setState(() {
                                                                                isLoading = false;
                                                                                isAllButtonPressed = false;
                                                                              });
                                                                            }
                                                                          : null,
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Visibility(
                                                                              visible: isLoading,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 10),
                                                                                child: SizedBox(
                                                                                    width: 15,
                                                                                    height: 15,
                                                                                    child: CircularProgressIndicator(color: Theme.of(context).buttonTheme.colorScheme!.onSurface)),
                                                                              )),
                                                                          const SizedBox(width: 10),
                                                                          Text(curLangText!.uiRemoveFromQuickApplyList)
                                                                        ],
                                                                      )),
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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Text(curLangText!.uiNoteMustSelectACustomAqmFileBeforeInject),
                                    Wrap(
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      spacing: 5,
                                      children: [
                                        // ElevatedButton(
                                        //     onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                        //         ? (() async {
                                        //             final prefs = await SharedPreferences.getInstance();
                                        //             if (modsAdderGroupSameItemVariants) {
                                        //               modsAdderGroupSameItemVariants = false;
                                        //               prefs.setBool('modsAdderGroupSameItemVariants', false);
                                        //             } else {
                                        //               modsAdderGroupSameItemVariants = true;
                                        //               prefs.setBool('modsAdderGroupSameItemVariants', true);
                                        //             }
                                        //             setState(
                                        //               () {},
                                        //             );
                                        //           })
                                        //         : null,
                                        //     child: Text(modsAdderGroupSameItemVariants
                                        //         ? '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiON}'
                                        //         : '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiOFF}')),
                                        ElevatedButton(
                                            onPressed: quickApplyItemList.isNotEmpty && !isAllButtonPressed
                                                ? () async {
                                                    setState(() {
                                                      isLoading = true;
                                                      isAllButtonPressed = true;
                                                    });
                                                    quickApplyItemList.clear();
                                                    //Save to json
                                                    quickSwapApplySelectedItems.map((item) => item.toJson()).toList();
                                                    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                                    File(modManQuickSwapApplyItemsJsonPath).writeAsStringSync(encoder.convert(quickSwapApplySelectedItems));

                                                    setState(() {
                                                      isLoading = false;
                                                      isAllButtonPressed = false;
                                                    });
                                                  }
                                                : null,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Visibility(
                                                    visible: isLoading,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Theme.of(context).buttonTheme.colorScheme!.onSurface)),
                                                    )),
                                                Visibility(visible: isLoading, child: const SizedBox(width: 10)),
                                                Text(curLangText!.uiRemoveAll)
                                              ],
                                            )),
                                        ElevatedButton(
                                            onPressed: () {
                                              selectedItemsSearchTextController.clear();
                                              availableItemsSearchTextController.clear();
                                              isLoading = false;
                                              isAllButtonPressed = false;
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

Future<List<CsvItem>> quickSwapApplyItemListGet() async {
  List<CsvItem> structureFromJson = [];

  // Load list from json
  String dataFromJson = await File(modManQuickSwapApplyItemsJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      structureFromJson.add(CsvItem.fromJson(item));
    }
  }

  return structureFromJson;
}
