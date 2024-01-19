import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

//Language Paths
String modManLanguageDirPath = '';
//Language Jsons Path
String modManSelectedLanguageJsonPath = '';
String modManLanguageSettingsJsonPath = '';

TranslationText? curLangText;
List<TranslationLanguage> languageList = [];

Future<TranslationText?> uiTextLoader() async {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  modManLanguageDirPath = Uri.file('${Directory.current.path}/Language').toFilePath();
  Directory(modManLanguageDirPath).createSync();
  modManLanguageSettingsJsonPath = Uri.file('$modManLanguageDirPath/LanguageSettings.json').toFilePath();
  if (!File(modManLanguageSettingsJsonPath).existsSync()) {
    File(modManLanguageSettingsJsonPath).createSync();
    //Create default EN language json
    String enUITextJsonPath = Uri.file('$modManLanguageDirPath/EN.json').toFilePath();
    File(enUITextJsonPath).createSync();
    languageList.add(TranslationLanguage('EN', enUITextJsonPath, true));
    TranslationText defaultENLanguage = TranslationText();
    //Write translation to json
    File(enUITextJsonPath).writeAsStringSync(encoder.convert(defaultENLanguage));
    //Add to language dropdown
    //langDropDownList.add(newLangTextController.text.toUpperCase());
    //Write to settings json
    languageList.map((lang) => lang.toJson()).toList();
    File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
    if (langDropDownList.indexWhere((element) => element == 'EN') == -1) {
      langDropDownList.add('EN');
    }
  } else if (kDebugMode) {
    String enUITextJsonPath = Uri.file('$modManLanguageDirPath/EN.json').toFilePath();
    if (!File(enUITextJsonPath).existsSync()) {
      File(enUITextJsonPath).createSync();
    }
    TranslationText defaultENLanguage = TranslationText();
    //Write translation to json
    File(enUITextJsonPath).writeAsStringSync(encoder.convert(defaultENLanguage));

    //Load local json
    var jsonData = jsonDecode(File(modManLanguageSettingsJsonPath).readAsStringSync());
    for (var lang in jsonData) {
      final langInfo = TranslationLanguage.fromJson(lang);
      if (languageList.where((element) => element.langFilePath == langInfo.langFilePath).isEmpty) {
        languageList.add(langInfo);
      }
    }

    //Load unlisted custom lang files
    final localCustomLang =
        Directory(modManLanguageDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.json' && p.basenameWithoutExtension(element.path).length == 2);
    for (var langFile in localCustomLang) {
      if (languageList.where((element) => element.langInitial == p.basenameWithoutExtension(langFile.path) && element.langFilePath == langFile.path).isEmpty) {
        languageList.add(TranslationLanguage(p.basenameWithoutExtension(langFile.path), langFile.path, curActiveLang == p.basenameWithoutExtension(langFile.path) ? true : false));
        File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
      }
    }

    //sort
    languageList.sort((a, b) => a.langInitial.compareTo(b.langInitial));

    for (var lang in languageList) {
      //Rewrite language file path
      if (!lang.langFilePath.contains(modManLanguageDirPath)) {
        lang.langFilePath = Uri.file('$modManLanguageDirPath/${lang.langInitial}.json').toFilePath();
        File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
      }
      if (!File(lang.langFilePath).existsSync()) {
        //Uri enUITextJsonPath = Uri.file('$modManLanguageDirPath${lang.langInitial}.json');
        File(lang.langFilePath).createSync();
        TranslationText defaultENLanguage = TranslationText();
        File(lang.langFilePath).writeAsStringSync(encoder.convert(defaultENLanguage));
      }
      if (!langDropDownList.contains(lang.langInitial)) {
        langDropDownList.add(lang.langInitial);
      }
    }
  } else {
    //Load local json
    var jsonData = jsonDecode(File(modManLanguageSettingsJsonPath).readAsStringSync());
    for (var lang in jsonData) {
      final langInfo = TranslationLanguage.fromJson(lang);
      if (languageList.where((element) => element.langFilePath == langInfo.langFilePath).isEmpty) {
        languageList.add(langInfo);
      }
    }

    for (var lang in languageList) {
      //Rewrite language file path
      if (!lang.langFilePath.contains(modManLanguageDirPath)) {
        lang.langFilePath = Uri.file('$modManLanguageDirPath/${lang.langInitial}.json').toFilePath();
        File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
      }
      if (!File(lang.langFilePath).existsSync()) {
        //Uri enUITextJsonPath = Uri.file('$modManLanguageDirPath${lang.langInitial}.json');
        File(lang.langFilePath).createSync();
        TranslationText defaultENLanguage = TranslationText();
        File(lang.langFilePath).writeAsStringSync(encoder.convert(defaultENLanguage));
      }
      if (!langDropDownList.contains(lang.langInitial)) {
        langDropDownList.add(lang.langInitial);
      }
    }
  }

  //check EN for update
  int enIndex = languageList.indexWhere((element) => element.langInitial == 'EN');
  List<String> enLangJsonTextLines = await File(languageList[enIndex].langFilePath).readAsLines();
  enLangJsonTextLines.removeAt(0);
  enLangJsonTextLines.removeLast();

  for (var lang in languageList) {
    if (lang.langInitial != 'EN') {
      List<String> curLangJsonTextLines = await File(lang.langFilePath).readAsLines();
      curLangJsonTextLines.removeAt(0);
      curLangJsonTextLines.removeLast();
      bool isChanged = false;
      for (var enLine in enLangJsonTextLines) {
        if (curLangJsonTextLines.where((element) => element.split(':').first == enLine.split(':').first).isEmpty) {
          if (enLangJsonTextLines.indexOf(enLine) >= curLangJsonTextLines.length && curLangJsonTextLines.last[curLangJsonTextLines.last.length - 1] != ',') {
            curLangJsonTextLines.last += ',';
          }
          curLangJsonTextLines.insert(enLangJsonTextLines.indexOf(enLine), enLine);
          isChanged = true;
        }
      }
      if (isChanged) {
        curLangJsonTextLines.insert(0, '{');
        curLangJsonTextLines.add('}');
        String curLangTextFinal = curLangJsonTextLines.join('\n');
        File(lang.langFilePath).writeAsStringSync(curLangTextFinal);
      }
    }
  }

  //load
  if (curActiveLang.isEmpty) {
    int selectedIndex = languageList.indexWhere((element) => element.selected);
    if (selectedIndex != -1) {
      langDropDownSelected = languageList[selectedIndex].langInitial;
      curActiveLang = languageList[selectedIndex].langInitial;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('curActiveLanguage', curActiveLang);
      var jsonData = jsonDecode(File(languageList[selectedIndex].langFilePath).readAsStringSync());
      return TranslationText.fromJson(jsonData);
    } else {
      int enIndex = languageList.indexWhere((element) => element.langInitial == 'EN');
      languageList[enIndex].selected = true;
      langDropDownSelected = languageList[enIndex].langInitial;
      curActiveLang = languageList[enIndex].langInitial;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('curActiveLanguage', curActiveLang);
      var jsonData = jsonDecode(File(languageList[enIndex].langFilePath).readAsStringSync());
      return TranslationText.fromJson(jsonData);
    }
  } else {
    for (var lang in languageList) {
      if (lang.langInitial != curActiveLang && lang.selected) {
        lang.selected = false;
      } else if (lang.langInitial == curActiveLang && !lang.selected) {
        lang.selected = true;
      }
    }
    File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
    int selectedIndex = languageList.indexWhere((element) => element.selected);
    if (selectedIndex != -1) {
      langDropDownSelected = languageList[selectedIndex].langInitial;
      var jsonData = jsonDecode(File(languageList[selectedIndex].langFilePath).readAsStringSync());
      File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
      return TranslationText.fromJson(jsonData);
    } else {
      int enIndex = languageList.indexWhere((element) => element.langInitial == 'EN');
      languageList[enIndex].selected = true;
      langDropDownSelected = languageList[enIndex].langInitial;
      curActiveLang = languageList[enIndex].langInitial;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('curActiveLanguage', curActiveLang);
      var jsonData = jsonDecode(File(languageList[enIndex].langFilePath).readAsStringSync());
      File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
      return TranslationText.fromJson(jsonData);
    }
    
  }
}