import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/ui_text.dart';

class LangLoadingPage extends StatefulWidget {
  const LangLoadingPage({Key? key}) : super(key: key);

  @override
  State<LangLoadingPage> createState() => _LangLoadingPageState();
}

class _LangLoadingPageState extends State<LangLoadingPage> {
  @override
  void initState() {
    getUILanguage();
    super.initState();
  }

  Future<void> getUILanguage() async {
    if (langList.isEmpty) {
      langList = await translationLoader();
      for (var lang in langList) {
        langDropDownList.add(lang.langInitial);
        if (lang.langFilePath != '$curLanguageDirPath$s${lang.langInitial}.json') {
          lang.langFilePath = '$curLanguageDirPath$s${lang.langInitial}.json';
          //Json Write
          langList.map((translation) => translation.toJson()).toList();
          File(langSettingsPath).writeAsStringSync(json.encode(langList));
        }
        if (lang.selected) {
          langDropDownSelected = lang.langInitial;
          curSelectedLangPath = '$curLanguageDirPath$s${lang.langInitial}.json';
        }
      }
    }

    if (curLangText == null) {
      convertLangTextData(jsonDecode(File(curSelectedLangPath).readAsStringSync()));
      //await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    }

    topBtnMenuItems = [curLangText!.modsFolderBtnText, curLangText!.backupFolderBtnText, curLangText!.deletedItemsBtnText];
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addTimingsCallback((_) async {
    //   await Future.delayed(const Duration(milliseconds: 500));
    //   if (curLangText == null) {
    //     await getUILanguage();
    //   }
    // });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          'Loading UI',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 20,
        ),
        CircularProgressIndicator(),
      ],
    );
  }
}
