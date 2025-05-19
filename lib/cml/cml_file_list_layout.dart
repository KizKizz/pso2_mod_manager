import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/cml/cml_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class CmlFileListLayout extends StatefulWidget {
  const CmlFileListLayout({super.key, required this.cmlFileList, required this.scrollController, required this.selectedCmlFile});

  final Signal<List<File>> cmlFileList;
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

    List<File> displayingCmlFiles = [];
    if (injectedItemSearchTextController.value.text.isEmpty) {
      displayingCmlFiles = widget.cmlFileList.value;
    } else {
      displayingCmlFiles = widget.cmlFileList.value.where((e) => p.basenameWithoutExtension(e.path).toLowerCase().contains(injectedItemSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
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
                  cursorColor: Theme.of(context).colorScheme.primary),
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
              hint: appText.search,
              controller: injectedItemSearchTextController,
              onSuggestionTap: (p0) {
                injectedItemSearchTextController.text = p0.searchKey;
                widget.selectedCmlFile.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return null;
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
        Row(
          spacing: 5,
          children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    await launchUrlString(modCustomCmlsDirPath);
                  },
                  child: Text(appText.openInFileExplorer)),
            ),
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
            )
          ],
        )
      ],
    );
  }
}
