import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/cml/cml_functions.dart';
import 'package:pso2_mod_manager/cml/cml_info_popup.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

bool showPremadeCmls = false;

class CmlFileListLayout extends StatefulWidget {
  const CmlFileListLayout({super.key, required this.cmlFileList, required this.cmlItemList, required this.scrollController, required this.selectedCmlFile});

  final Signal<List<File>> cmlFileList;
  final List<Cml> cmlItemList;
  final ScrollController scrollController;
  final Signal<File?> selectedCmlFile;

  @override
  State<CmlFileListLayout> createState() => _CmlItemListLayoutState();
}

class _CmlItemListLayoutState extends State<CmlFileListLayout> {
  TextEditingController injectedItemSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modAqmInjectingRefresh.watch(context) != modAqmInjectingRefresh.peek()) setState(() {});
    List<Cml> displayingCml = [];
    Directory extractedOriginDir = Directory('$modCMLReplaceTempDirPath${p.separator}original${p.separator}${p.basenameWithoutExtension(makerIceFile.path)}_ext${p.separator}group1');

    if (showPremadeCmls) {
      if (injectedItemSearchTextController.value.text.isEmpty) {
        displayingCml = widget.cmlItemList;
      } else {
        displayingCml = widget.cmlItemList.where((e) => e.getName().toLowerCase().contains(injectedItemSearchTextController.value.text.toLowerCase())).toList();
      }
    }

    List<File> displayingCmlFiles = [];
    if (injectedItemSearchTextController.value.text.isEmpty) {
      displayingCmlFiles = widget.cmlFileList.value;
    } else {
      displayingCmlFiles = widget.cmlFileList.value.where((e) => p.basenameWithoutExtension(e.path).toLowerCase().contains(injectedItemSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        // Search Boxes
        if (!showPremadeCmls)
          SizedBox(
            height: 30,
            child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
              SearchField<File>(
                itemHeight: 45,
                searchInputDecoration: SearchInputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                    isDense: true,
                    contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                    cursorHeight: 15,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    hintText: appText.search),
                suggestions: displayingCmlFiles
                    .map(
                      (e) => SearchFieldListItem(
                        p.basename(e.path),
                        item: e,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              spacing: 5,
                              children: [Text(p.basename(e.path))],
                            )),
                      ),
                    )
                    .toList(),
                controller: injectedItemSearchTextController,
                onSuggestionTap: (p0) {
                  injectedItemSearchTextController.text = p0.searchKey;
                  widget.selectedCmlFile.value = p0.item;
                  setState(() {});
                },
                onSearchTextChanged: (p0) {
                  setState(() {});
                  return displayingCmlFiles
                      .map(
                        (e) => SearchFieldListItem(
                          p.basename(e.path),
                          item: e,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                spacing: 5,
                                children: [Text(p.basename(e.path))],
                              )),
                        ),
                      )
                      .toList();
                },
              ),
              Visibility(
                visible: injectedItemSearchTextController.value.text.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: IconButton(
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onPressed: injectedItemSearchTextController.value.text.isNotEmpty
                          ? () {
                              injectedItemSearchTextController.clear();
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.close)),
                ),
              )
            ]),
          ),

        if (showPremadeCmls)
          SizedBox(
            height: 30,
            child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
              SearchField<Cml>(
                itemHeight: 90,
                searchInputDecoration: SearchInputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                    isDense: true,
                    contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                    cursorHeight: 15,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    hintText: appText.search),
                suggestions: displayingCml
                    .map(
                      (e) => SearchFieldListItem(
                        e.getName(),
                        item: e,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              spacing: 5,
                              children: [
                                GenericItemIconBox(iconImagePaths: [e.cloudItemIconPath], boxSize: const Size(70, 70), isNetwork: true),
                                Text(e.getName())
                              ],
                            )),
                      ),
                    )
                    .toList(),
                controller: injectedItemSearchTextController,
                onSuggestionTap: (p0) {
                  injectedItemSearchTextController.text = p0.searchKey;
                  setState(() {});
                },
                onSearchTextChanged: (p0) {
                  setState(() {});
                  return displayingCml
                      .map(
                        (e) => SearchFieldListItem(
                          e.getName(),
                          item: e,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                spacing: 5,
                                children: [
                                  GenericItemIconBox(iconImagePaths: [e.cloudItemIconPath], boxSize: const Size(70, 70), isNetwork: true),
                                  Text(e.getName())
                                ],
                              )),
                        ),
                      )
                      .toList();
                },
              ),
              Visibility(
                visible: injectedItemSearchTextController.value.text.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: IconButton(
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onPressed: injectedItemSearchTextController.value.text.isNotEmpty
                          ? () {
                              injectedItemSearchTextController.clear();
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.close)),
                ),
              )
            ]),
          ),

        // Lists
        if (!showPremadeCmls)
          Expanded(
              child: CardOverlay(
                  paddingValue: 5,
                  child: SuperListView.builder(
                    physics: const SuperRangeMaintainingScrollPhysics(),
                    controller: widget.scrollController,
                    itemCount: displayingCmlFiles.length,
                    itemBuilder: (context, index) {
                      return ListTileTheme(
                        data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        child: ListTile(
                          minTileHeight: 45,
                          title: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.basename(displayingCmlFiles[index].path),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.outlined(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onPressed: () async {
                                  final newName = await renamePopup(context, p.dirname(displayingCmlFiles[index].path), p.basenameWithoutExtension(displayingCmlFiles[index].path));
                                  if (newName != null) {
                                    final oldName = p.basename(displayingCmlFiles[index].path);
                                    final renamedFile =
                                        await displayingCmlFiles[index].rename(p.dirname(displayingCmlFiles[index].path) + p.separator + newName + p.extension(displayingCmlFiles[index].path));
                                    for (var item in masterCMLItemList.where((e) => e.isReplaced)) {
                                      if (oldName == item.replacedCmlFileName) {
                                        item.replacedCmlFileName = p.basename(renamedFile.path);
                                      }
                                      saveMasterCmlItemListToJson();
                                    }
                                    widget.cmlFileList.value = Directory(modCustomCmlsDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.cml').toList();
                                    mainGridStatus.value = '$oldName.cml has been renamed to $newName';
                                  }
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton.outlined(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onPressed: () async {
                                  final delete = await deleteConfirmPopup(context, p.basename(displayingCmlFiles[index].path));
                                  if (delete) {
                                    await displayingCmlFiles[index].delete();
                                    widget.cmlFileList.value.remove(displayingCmlFiles[index]);
                                    setState(() {});
                                  }
                                },
                                icon: Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                              ),
                            ],
                          ),
                          selected: widget.selectedCmlFile.watch(context) == displayingCmlFiles[index],
                          onTap: () {
                            widget.selectedCmlFile.value = displayingCmlFiles[index];
                          },
                        ),
                      );
                    },
                  ))),

        if (showPremadeCmls)
          Expanded(
              child: CardOverlay(
                  paddingValue: 5,
                  child: SuperListView.builder(
                    physics: const SuperRangeMaintainingScrollPhysics(),
                    controller: widget.scrollController,
                    itemCount: displayingCml.length,
                    itemBuilder: (context, index) {
                      return ListTileTheme(
                        data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        child: ListTile(
                          minTileHeight: 90,
                          title: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GenericItemIconBox(iconImagePaths: [displayingCml[index].cloudItemIconPath], boxSize: const Size(80, 80), isNetwork: true),
                              Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayingCml[index].getName(),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text('pl_cp_${displayingCml[index].aId}.cml', style: TextStyle(fontSize: 12)),
                                  Visibility(
                                      visible: displayingCml[index].isReplaced,
                                      child: Text(appText.dText(appText.replacedCMLFile, displayingCml[index].replacedCmlFileName), style: Theme.of(context).textTheme.labelMedium))
                                ],
                              ),
                            ],
                          ),
                          enabled: File('${extractedOriginDir.path}${p.separator}pl_cp_${displayingCml[index].aId}.cml').existsSync(),
                          selected: widget.selectedCmlFile.watch(context) != null && widget.selectedCmlFile.watch(context)!.path == '${extractedOriginDir.path}${p.separator}pl_cp_${displayingCml[index].aId}.cml',
                          onTap: () {
                            widget.selectedCmlFile.value = File('${extractedOriginDir.path}${p.separator}pl_cp_${displayingCml[index].aId}.cml');
                          },
                        ),
                      );
                    },
                  ))),
        Row(
          spacing: 5,
          children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    showPremadeCmls ? showPremadeCmls = false : showPremadeCmls = true;
                    widget.selectedCmlFile.value = null;
                    setState(() {});
                  },
                  child: Text(showPremadeCmls ? appText.showCustomCmlFiles : appText.showPremades)),
            ),
            if (!showPremadeCmls)
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      await launchUrlString(modCustomCmlsDirPath);
                    },
                    child: Text(
                      appText.openInFileExplorer,
                      textAlign: TextAlign.center,
                    )),
              ),
            if (!showPremadeCmls)
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      const XTypeGroup aqmTypeGroup = XTypeGroup(
                        label: 'CML',
                        extensions: <String>['cml'],
                      );
                      final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
                        aqmTypeGroup,
                      ]);
                      for (var file in files) {
                        await File(file.path).copy(modCustomCmlsDirPath + p.separator + p.basename(file.path));
                      }
                      widget.cmlFileList.value = Directory(modCustomCmlsDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.cml').toList();
                      setState(() {});
                    },
                    child: Text(appText.addFiles)),
              ),
            ElevatedButton.icon(
                onPressed: () => cmlInfoPopup(context),
                label: Row(
                  spacing: 5,
                  children: [Icon(Icons.help_outline), Text(appText.help)],
                ))
          ],
        )
      ],
    );
  }
}
