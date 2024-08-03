// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_add_function.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_swappage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_swappage.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

TextEditingController selectedItemsSearchTextController = TextEditingController();
TextEditingController availableItemsSearchTextController = TextEditingController();
String fromItemIconLink = '';
String toItemIconLink = '';
bool isLoading = false;
bool isAllButtonPressed = false;
List<CsvItem> swapToItemList = [];
List<CsvItem> selectedItems = [];
List<bool> _selectedSwapFromSubmods = [];

late Future availableItemListFetch;

// ignore: must_be_immutable
class SwapAllHomePage extends StatefulWidget {
  SwapAllHomePage({super.key, this.swapItem});

  Item? swapItem;

  @override
  State<SwapAllHomePage> createState() => _AqmInjectionHomePageState();
}

class _AqmInjectionHomePageState extends State<SwapAllHomePage> {
  @override
  void initState() {
    // //clear
    // if (Directory(modManAddModsTempDirPath).existsSync()) {
    //   Directory(modManAddModsTempDirPath).deleteSync(recursive: true);
    // }
    _selectedSwapFromSubmods.clear();
    availableItemListFetch = getAvailableItems(widget.swapItem!.category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder(
              future: availableItemListFetch,
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
                          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(snapshot.error.toString()))
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
                    List<CsvItem> availableCsvItems = snapshot.data;
                    //available Items
                    List<CsvItem> availableItem = [];
                    if (availableItemsSearchTextController.text.isEmpty) {
                      availableItem = availableCsvItems.where((e) => modManCurActiveItemNameLanguage == 'JP' ? e.getJPName().isNotEmpty : e.getENName().isNotEmpty).toList();
                    } else {
                      availableItem = availableCsvItems
                          .where((e) =>
                              (modManCurActiveItemNameLanguage == 'JP' ? e.getJPName().isNotEmpty : e.getENName().isNotEmpty) &&
                              (e.getENName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase()) ||
                                  e.getJPName().toLowerCase().contains(availableItemsSearchTextController.text.toLowerCase())))
                          .toList();
                    }

                    if (selectedItemsSearchTextController.text.isEmpty) {
                      swapToItemList = selectedItems;
                    } else {
                      swapToItemList = selectedItems
                          .where((e) =>
                              e.getENName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()) ||
                              e.getJPName().toLowerCase().contains(selectedItemsSearchTextController.text.toLowerCase()))
                          .toList();
                    }
                    List<SubMod> swapFromSubmods = widget.swapItem!.getSubmods();

                    return Row(
                      children: [
                        RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'SWAP ALL',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 10),
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
                                                      child: widget.swapItem!.icons.first.contains('assets/img/placeholdersquare.png')
                                                          ? Image.asset(
                                                              'assets/img/placeholdersquare.png',
                                                              filterQuality: FilterQuality.none,
                                                              fit: BoxFit.fitWidth,
                                                            )
                                                          : Image.file(
                                                              File(widget.swapItem!.icons.first),
                                                              filterQuality: FilterQuality.none,
                                                              fit: BoxFit.fitWidth,
                                                            )),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        widget.swapItem!.category,
                                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                                      ),
                                                      Text(widget.swapItem!.itemName.replaceFirst('_', '/'), style: const TextStyle(fontWeight: FontWeight.w500)),
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 5, right: 2.5),
                                                            child: Container(
                                                              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                              ),
                                                              child: Text(
                                                                widget.swapItem!.mods.length < 2
                                                                    ? '${widget.swapItem!.mods.length} ${curLangText!.uiMod}'
                                                                    : '${widget.swapItem!.mods.length} ${curLangText!.uiMods}',
                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 5, left: 2.5, right: 2.5),
                                                            child: Container(
                                                              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                              ),
                                                              child: Text(
                                                                widget.swapItem!.getSubmods().length < 2
                                                                    ? '${widget.swapItem!.getSubmods().length} ${curLangText!.uiVariant}'
                                                                    : '${widget.swapItem!.getSubmods().length} ${curLangText!.uiVariants}',
                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 5, left: 2.5),
                                                            child: Container(
                                                              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                              ),
                                                              child: Text(
                                                                _selectedSwapFromSubmods.isNotEmpty
                                                                    ? '${curLangText!.uiSelected}: ${_selectedSwapFromSubmods.where((e) => e).length}'
                                                                    : '${curLangText!.uiSelected}: ${widget.swapItem!.getSubmods().length}',
                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              //swap from mods
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
                                                        child: SuperListView.builder(
                                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                            // shrinkWrap: true,
                                                            physics: const RangeMaintainingScrollPhysics(),
                                                            itemCount: widget.swapItem!.getSubmods().length,
                                                            itemBuilder: (context, i) {
                                                              if (_selectedSwapFromSubmods.isEmpty || _selectedSwapFromSubmods.length != swapFromSubmods.length) {
                                                                _selectedSwapFromSubmods = List.generate(swapFromSubmods.length, (index) => true);
                                                              }
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                                child: CheckboxListTile(
                                                                  shape: RoundedRectangleBorder(
                                                                      side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                  activeColor: Theme.of(context).buttonTheme.colorScheme!.primary,
                                                                  title: Text('${swapFromSubmods[i].modName} > ${swapFromSubmods[i].submodName}'),
                                                                  value: _selectedSwapFromSubmods[i],
                                                                  onChanged: (bool? value) {
                                                                    if (value!) {
                                                                      _selectedSwapFromSubmods[i] = true;
                                                                    } else {
                                                                      _selectedSwapFromSubmods[i] = false;
                                                                    }
                                                                    setState(() {});
                                                                  },
                                                                ),
                                                              );
                                                            }))),
                                              ),

                                              const RotatedBox(quarterTurns: 3, child: Icon(Icons.arrow_back_ios_new_rounded)),

                                              //selected items
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
                                                        child: SuperListView.builder(
                                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                            // shrinkWrap: true,
                                                            physics: const RangeMaintainingScrollPhysics(),
                                                            itemCount: swapToItemList.length,
                                                            itemBuilder: (context, i) {
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                                child: ListTile(
                                                                    shape: RoundedRectangleBorder(
                                                                        side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                                                                                '$modManMAIconDatabaseLink${swapToItemList[i].iconImagePath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
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
                                                                                    ? Text(swapToItemList[i].getJPName().trim())
                                                                                    : Text(swapToItemList[i].getENName().trim()),
                                                                                const SizedBox(height: 10),
                                                                                Text(
                                                                                    availableItem[i].getENName().contains('[Se]')
                                                                                        ? '${curLangText!.uiCategory}: ${defaultCategoryNames[16]}'
                                                                                        : '${curLangText!.uiCategory}: ${defaultCategoryNames[swapToItemList[i].categoryIndex]}',
                                                                                    style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                                                              ],
                                                                            )),
                                                                      ]),
                                                                      ElevatedButton(
                                                                          onPressed: !isAllButtonPressed
                                                                              ? () async {
                                                                                  setState(() {
                                                                                    isLoading = true;
                                                                                    isAllButtonPressed = true;
                                                                                  });
                                                                                  selectedItems.removeAt(i);

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
                                                                              // Visibility(
                                                                              //     visible: isLoading,
                                                                              //     child: Padding(
                                                                              //       padding: const EdgeInsets.only(right: 10),
                                                                              //       child: SizedBox(
                                                                              //           width: 15,
                                                                              //           height: 15,
                                                                              //           child: CircularProgressIndicator(color: Theme.of(context).buttonTheme.colorScheme!.onSurface)),
                                                                              //     )),
                                                                              // Visibility(visible: isLoading, child: const SizedBox(width: 10)),
                                                                              Text(curLangText!.uiRemove)
                                                                            ],
                                                                          )),
                                                                    ])),
                                                              );
                                                            }))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),

                                    // const Padding(
                                    //   padding: EdgeInsets.symmetric(horizontal: 0),
                                    //   child: Icon(
                                    //     Icons.arrow_forward_ios_rounded,
                                    //     size: 25,
                                    //   ),
                                    // ),

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
                                                        availableItem = availableCsvItems;
                                                      } else {
                                                        availableItem = availableCsvItems
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
                                                    child: SuperListView.builder(
                                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                        // shrinkWrap: true,
                                                        physics: const RangeMaintainingScrollPhysics(),
                                                        itemCount: availableItem.length,
                                                        itemBuilder: (context, i) {
                                                          return Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                                              child: ListTile(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                                                                  ElevatedButton(
                                                                      onPressed: swapToItemList
                                                                              .where((e) => e.getENName() == availableItem[i].getENName() || e.getJPName() == availableItem[i].getJPName())
                                                                              .isEmpty
                                                                          ? () async {
                                                                              selectedItems.add(availableItem[i]);
                                                                              setState(() {});
                                                                            }
                                                                          : null,
                                                                      child: Text(curLangText!.uiSelect)),
                                                                ]),
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
                                        ElevatedButton(
                                            onPressed: swapToItemList.isNotEmpty && !isAllButtonPressed
                                                ? () async {
                                                    setState(() {
                                                      isLoading = true;
                                                      isAllButtonPressed = true;
                                                    });
                                                    swapToItemList.clear();
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
                                                // Visibility(
                                                //     visible: isLoading,
                                                //     child: Padding(
                                                //       padding: const EdgeInsets.only(right: 10),
                                                //       child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Theme.of(context).buttonTheme.colorScheme!.onSurface)),
                                                //     )),
                                                // Visibility(visible: isLoading, child: const SizedBox(width: 10)),
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
                                        ElevatedButton(
                                            onPressed: swapToItemList.isNotEmpty && !isAllButtonPressed
                                                ? () async {
                                                    setState(() {
                                                      isLoading = true;
                                                      isAllButtonPressed = true;
                                                    });
                                                    List<SubMod> submodsToSwap = [];
                                                    for (int i = 0; i < _selectedSwapFromSubmods.length; i++) {
                                                      if (_selectedSwapFromSubmods[i]) {
                                                        submodsToSwap.add(swapFromSubmods[i]);
                                                      }
                                                    }
                                                    await swapAllPopup(context, widget.swapItem!.mods, submodsToSwap, swapToItemList);
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
                                                // Visibility(
                                                //     visible: isLoading,
                                                //     child: Padding(
                                                //       padding: const EdgeInsets.only(right: 10),
                                                //       child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Theme.of(context).buttonTheme.colorScheme!.onSurface)),
                                                //     )),
                                                // Visibility(visible: isLoading, child: const SizedBox(width: 10)),
                                                Text(curLangText!.uiSwap)
                                              ],
                                            )),
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

Future<bool> swapAllPopup(context, List<Mod> mods, List<SubMod> submods, List<CsvItem> swapToItems) async {
  List<int> totalSwapped = List.generate(swapToItems.length, (index) => 0);
  bool isSwapped = false;
  bool isSwapping = false;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!isSwapping && !isSwapped) {
              isSwapping = true;
              for (var item in swapToItems) {
                for (var submod in submods) {
                  SubMod? swappedSub = await swapAll(context, mods.firstWhere((e) => e.modName == submod.modName && submod.location.contains(e.location)), submod, item);
                  if (swappedSub != null) totalSwapped[swapToItems.indexOf(item)]++;
                  swappedSub = null;
                  setState(
                    () {},
                  );
                }
              }
              isSwapping = false;
              isSwapped = true;
            }
          });
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 250, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        curLangText!.uiSwapAllMods,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Visibility(
                      visible: !isSwapped || isSwapping,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: SizedBox(width: 25, height: 25, child: CircularProgressIndicator()),
                      ),
                    ),
                    Visibility(
                      visible: isSwapped,
                      child: const Padding(padding: EdgeInsets.only(top: 20), child: SizedBox(width: 25, height: 25)),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(!isSwapped || isSwapping
                            ? curLangText!.uiProcessing
                            : isSwapped && !isSwapping
                                ? curLangText!.uiAllDone
                                : '')),
                    SizedBox(
                      height: (50 * double.parse(swapToItems.length.toString())) + 8,
                      width: 400,
                      child: Card(
                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                        child: ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                }
                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                              }),
                            ),
                            child: SuperListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                physics: const RangeMaintainingScrollPhysics(),
                                itemCount: swapToItems.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                      minTileHeight: 50,
                                      title: Text(modManCurActiveItemNameLanguage == 'JP' ? swapToItems[i].getJPName() : swapToItems[i].getENName()),
                                      subtitle: Text('${totalSwapped[i]} / ${submods.length}'),
                                      titleTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      subtitleTextStyle: const TextStyle(fontSize: 12));
                                })),
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                            onPressed: !isSwapping && isSwapped
                                ? () {
                                    clearAllTempDirs();
                                    isSwapped = false;
                                    totalSwapped = [];
                                    Navigator.pop(context, true);
                                  }
                                : null,
                            child: Text(curLangText!.uiReturn)),
                      ),
                    ),
                  ],
                ),
              ));
        });
      });
}

Future<List<CsvItem>> getAvailableItems(String category) async {
  return playerItemData
      .where((e) =>
          (e.category == category ||
              (category == defaultCategoryDirs[16] && e.category == defaultCategoryDirs[1]) ||
              (category == defaultCategoryDirs[2] && e.category == defaultCategoryDirs[11]) ||
              (category == defaultCategoryDirs[11] && e.category == defaultCategoryDirs[2])) &&
          (e.infos.entries.firstWhere((i) => i.key == 'High Quality').value.isNotEmpty || e.infos.entries.firstWhere((i) => i.key == 'Normal Quality').value.isNotEmpty))
      .toList();
}

Future<SubMod?> swapAll(context, Mod mod, SubMod submod, CsvItem swapToItem) async {
  bool found = false;
  Item? swapItem;
  Mod? swapMod;
  SubMod? swapSubmod;
  //precheck
  for (var cateType in moddedItemsList) {
    for (var cate
        in cateType.categories.where((element) => element.categoryName == swapToItem.category || (element.categoryName == defaultCategoryDirs[1] && submod.category == defaultCategoryDirs[16]))) {
      for (var item in cate.items) {
        if (item.itemName == swapToItem.getENName().replaceAll(RegExp(charToReplace), '_').trim() || item.itemName == swapToItem.getJPName().replaceAll(RegExp(charToReplace), '_').trim()) {
          for (var mod in item.mods) {
            if (mod.modName == submod.modName) {
              for (var sub in mod.submods) {
                if (sub.submodName == submod.submodName || sub.submodName == submod.submodName) {
                  swapItem = item;
                  swapMod = mod;
                  swapSubmod = sub;
                  found = true;
                  break;
                }
              }
            }
          }
        }
      }
    }
  }
  if (!found) {
    swapItem = null;
    swapMod = null;
    swapSubmod = null;
    if (defaultCategoryDirs.indexOf(submod.category) == 0) {
      //swapping acc
      //from
      CsvItem? filteredFromItem = playerItemData.firstWhere((element) => element.category == defaultCategoryDirs[0] && element.containsIceFiles(submod.getModFileNames()));
      CsvIceFile fromItem = CsvIceFile.fromList(filteredFromItem.getInfos());
      final fromItemIces = fromItem.getDetailedList().where((element) => element.split(': ').last.isNotEmpty && submod.getModFileNames().contains(element.split(': ').last)).toList();
      //to
      CsvIceFile toItem = CsvIceFile.fromList(swapToItem.getInfos());
      List<String> toItemIces = [];
      for (var line in toItem.getDetailedList()) {
        if (fromItemIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
          toItemIces.add(line);
        }
      }

      String swappedPath =
          await modsSwapperAccIceFilesGet(context, false, mod, submod, fromItemIces, toItemIces, modManCurActiveItemNameLanguage == 'JP' ? swapToItem.getJPName() : swapToItem.getENName());
      //adding
      if (Directory(swappedPath).existsSync()) {
        var returnedVar = await modsAdderModFilesAdder(
            context,
            await modsAdderFilesProcess(context, [XFile(Uri.file('$swappedPath/${submod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath())],
                modManCurActiveItemNameLanguage == 'JP' ? swapToItem.getJPName() : swapToItem.getENName()));
        List<Item> returnedItems = returnedVar.$2;
        swapItem = returnedItems.first;
        swapMod = swapItem.mods.firstWhere((e) => e.modName == submod.modName);
        swapSubmod = swapMod.submods.firstWhere((e) => e.submodName == submod.submodName);
      }
    } else {
      //swapping
      //from
      CsvItem? filteredFromItem = playerItemData.firstWhere((element) =>
          (element.category == submod.category ||
              (submod.category == defaultCategoryDirs[16] && element.category == defaultCategoryDirs[1]) ||
              (submod.category == defaultCategoryDirs[2] && element.category == defaultCategoryDirs[11]) ||
              (submod.category == defaultCategoryDirs[11] && element.category == defaultCategoryDirs[2])) &&
          element.containsIceFiles(submod.getModFileNames()));
      CsvIceFile fromItem = CsvIceFile.fromList(filteredFromItem.getInfos());
      final fromItemIces = fromItem.getDetailedList().where((element) => element.split(': ').last.isNotEmpty && submod.getModFileNames().contains(element.split(': ').last)).toList();
      String fromItemId = fromItem.id.toString();
      //to
      CsvIceFile toItem = CsvIceFile.fromList(swapToItem.getInfos());
      List<String> toItemIces = [];
      for (var line in toItem.getDetailedList()) {
        if (fromItemIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
          toItemIces.add(line);
        }
      }
      String toItemId = toItem.id.toString();

      String swappedPath = await modsSwapperIceFilesGet(
          context, false, mod, submod, fromItemIces, toItemIces, modManCurActiveItemNameLanguage == 'JP' ? swapToItem.getJPName() : swapToItem.getENName(), fromItemId, toItemId);
      //adding
      if (Directory(swappedPath).existsSync()) {
        try {
          var returnedVar = await modsAdderModFilesAdder(
              context,
              await modsAdderFilesProcess(context, [XFile(Uri.file('$swappedPath/${submod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath())],
                  modManCurActiveItemNameLanguage == 'JP' ? swapToItem.getJPName() : swapToItem.getENName()));
          List<Item> returnedItems = returnedVar.$2;
          swapItem = returnedItems.first;
          swapMod = swapItem.mods.firstWhere((e) => e.modName == submod.modName);
          swapSubmod = swapMod.submods.firstWhere((e) => e.submodName == submod.submodName);
        } catch (e) {
          return swapSubmod;
        }
      }
    }
  }

  return swapSubmod;
}
