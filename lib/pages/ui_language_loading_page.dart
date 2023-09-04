import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/pages/paths_loading_page.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class UILanguageLoadingPage extends StatefulWidget {
  const UILanguageLoadingPage({Key? key}) : super(key: key);

  @override
  State<UILanguageLoadingPage> createState() => _UILanguageLoadingPageState();
}

class _UILanguageLoadingPageState extends State<UILanguageLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: uiTextLoader(),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Loading UI',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
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
                      'Error when loading UI',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          windowManager.destroy();
                        },
                        child: const Text('Exit'))
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading UI',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              curLangText = snapshot.data;
              if (!firstTimeLanguageSet) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Select language\n言語を選択',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),

                        SizedBox(
                          width: 70,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                            style: const TextStyle(fontWeight: FontWeight.w400),
                            buttonStyleData: ButtonStyleData(
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              elevation: 3,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                              ),
                            ),
                            iconStyleData: const IconStyleData(iconSize: 20),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                            ),
                            isDense: true,
                            items: langDropDownList
                                .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(bottom: 3),
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                              //color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    )))
                                .toList(),
                            value: langDropDownSelected,
                            onChanged: (value) async {
                              langDropDownSelected = value.toString();
                              for (var lang in languageList) {
                                if (lang.langInitial == value) {
                                  lang.selected = true;
                                  curActiveLang = lang.langInitial;
                                  var jsonData = jsonDecode(File(lang.langFilePath).readAsStringSync());
                                  curLangText = TranslationText.fromJson(jsonData);
                                } else {
                                  lang.selected = false;
                                }
                              }

                              //Json Write
                              const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                              languageList.map((lang) => lang.toJson()).toList();
                              File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
                              setState(() {});
                            },
                          )),
                        ),

                        //button
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                firstTimeLanguageSet = true;
                                prefs.setBool('firstTimeLanguageSet', true);
                                setState(() {});
                              },
                              child: Text(curLangText!.uiGotIt)),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const PathsLoadingPage();
              }
            }
          }
        });
  }
}
