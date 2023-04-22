import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/ui_text.dart';

//Language Paths
Uri modManLanguageDirPath = Uri();
//Language Jsons Path
Uri modManSelectedLanguageJsonPath = Uri();
Uri modManLanguageSettingsJsonPath = Uri();

TranslationText? curLangText;
List<TranslationLanguage> languageList = [];

Future<TranslationText> uiTextLoader() async {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  modManLanguageDirPath = Uri.directory('${Directory.current.path}\\Language');
  Directory(modManLanguageDirPath.toFilePath()).createSync();
  modManLanguageSettingsJsonPath = Uri.file('${Directory.current.path}\\Language\\LanguageSettings.json');
  if (!File(modManLanguageSettingsJsonPath.toFilePath()).existsSync()) {
    File(modManLanguageSettingsJsonPath.toFilePath()).createSync();
    //Create default EN language json
    Uri enUITextJsonPath = Uri.file('$modManLanguageDirPath\\EN.json');
    File(enUITextJsonPath.toFilePath()).createSync();
    languageList.add(TranslationLanguage('EN', enUITextJsonPath, true));
    TranslationText defaultENLanguage = defaultUILangLoader();
    //Write translation to json
    File(enUITextJsonPath.toFilePath()).writeAsStringSync(encoder.convert(defaultENLanguage));
    //Add to language dropdown
    //langDropDownList.add(newLangTextController.text.toUpperCase());
    //Write to settings json
    languageList.map((lang) => lang.toJson()).toList();
    File(modManLanguageSettingsJsonPath.toFilePath()).writeAsStringSync(encoder.convert(languageList));
    langDropDownList.add('EN');
  } else {
    //Load local json
    var jsonData = jsonDecode(File(modManLanguageSettingsJsonPath.toFilePath()).readAsStringSync());
    //List<TranslationLanguage> languagesFromJson = [];
    for (var lang in jsonData) {
      languageList.add(TranslationLanguage.fromJson(lang));
    }

    for (var lang in languageList) {
      if (!File(lang.langFilePath.path).existsSync()) {
        //Uri enUITextJsonPath = Uri.file('$modManLanguageDirPath${lang.langInitial}.json');
        File(lang.langFilePath.path).createSync();
        TranslationText defaultENLanguage = defaultUILangLoader();
        File(lang.langFilePath.path).writeAsStringSync(encoder.convert(defaultENLanguage));
      }
    }
  }

  //TranslationText returnLanguage;
  int selectedIndex = languageList.indexWhere((element) => element.selected);
  if (selectedIndex != -1) {
    langDropDownList.add(languageList[selectedIndex].langInitial);
    langDropDownSelected = languageList[selectedIndex].langInitial;
    var jsonData = jsonDecode(File(languageList[selectedIndex].langFilePath.path).readAsStringSync());

    //returnLanguage = TranslationText.fromJson(jsonData);
    return TranslationText.fromJson(jsonData);
  } else {
    int enIndex = languageList.indexWhere((element) => element.langInitial == 'EN');
    languageList[enIndex].selected = true;
    langDropDownList.add(languageList[enIndex].langInitial);
    langDropDownSelected = languageList[enIndex].langInitial;
    var jsonData = jsonDecode(File(languageList[enIndex].langFilePath.toFilePath()).readAsStringSync());

    //returnLanguage = TranslationText.fromJson(jsonData);
    return TranslationText.fromJson(jsonData);
  }

  //return returnLanguage;
}

// Future<void> languagePackCheck() async {
//     curLanguageDirPath = '${Directory.current.path}${s}Language';
//     langSettingsPath = '${Directory.current.path}${s}Language${s}LanguageSettings.json';

//     if (!File(langSettingsPath).existsSync()) {
//       await File(langSettingsPath).create(recursive: true);
//       TranslationLanguage newENLang = TranslationLanguage('EN', '$curLanguageDirPath${s}EN.json', true);
//       await File('$curLanguageDirPath${s}EN.json').create(recursive: true);
//       TranslationText newEN = defaultUILangLoader();
//       //Json Write
//       [newEN].map((translationText) => translationText.toJson()).toList();
//       File('$curLanguageDirPath${s}EN.json').writeAsStringSync(json.encode([newEN]));
//       langList.add(newENLang);
//       langDropDownList.add(newLangTextController.text.toUpperCase());
//       //Json Write
//       langList.map((translation) => translation.toJson()).toList();
//       File(langSettingsPath).writeAsStringSync(json.encode(langList));
//       langList = await translationLoader();
//       for (var lang in langList) {
//         langDropDownList.add(lang.langInitial);
//         if (lang.langFilePath != '$curLanguageDirPath$s${lang.langInitial}.json') {
//           lang.langFilePath = '$curLanguageDirPath$s${lang.langInitial}.json';
//           //Json Write
//           langList.map((translation) => translation.toJson()).toList();
//           File(langSettingsPath).writeAsStringSync(json.encode(langList));
//         }
//         if (lang.selected) {
//           langDropDownSelected = lang.langInitial;
//           curSelectedLangPath = '$curLanguageDirPath$s${lang.langInitial}.json';
//         }
//       }
//     } else {
//       List<TranslationLanguage> tempLangList = await translationLoader();
//       for (var lang in tempLangList) {
//         if (!File(lang.langFilePath).existsSync()) {
//           if (lang.selected) {
//             if (lang.langInitial != 'EN') {
//               tempLangList.singleWhere((element) => element.langInitial == 'EN').selected = true;
//             } else {
//               await File('$curLanguageDirPath${s}EN.json').create(recursive: true);
//               TranslationText newEN = defaultUILangLoader();
//               //Json Write
//               [newEN].map((translationText) => translationText.toJson()).toList();
//               File('$curLanguageDirPath${s}EN.json').writeAsStringSync(json.encode([newEN]));
//             }
//           }
//         } else {
//           if (lang.langInitial == 'EN') {
//             TranslationText newEN = defaultUILangLoader();
//             //Json Write
//             [newEN].map((translationText) => translationText.toJson()).toList();
//             File(lang.langFilePath).writeAsStringSync(json.encode([newEN]));
//           } else {
//             String curLangString = File('$curLanguageDirPath${s}EN.json').readAsStringSync();
//             curLangString = curLangString.replaceRange(0, 2, '');
//             curLangString = curLangString.replaceRange(curLangString.length - 2, null, '');
//             List<String> newTranslationItems = curLangString.split('",');
//             String tempTranslationFromFile = File(lang.langFilePath).readAsStringSync();
//             tempTranslationFromFile = tempTranslationFromFile.replaceRange(0, 2, '');
//             tempTranslationFromFile = tempTranslationFromFile.replaceRange(tempTranslationFromFile.length - 2, null, '');
//             List<String> curTranslationItems = tempTranslationFromFile.split('",');
//             curTranslationItems.last = curTranslationItems.last.replaceRange(curTranslationItems.last.length - 1, null, '');
//             String curLastItem = curTranslationItems.last;

//             if (newTranslationItems.length != curTranslationItems.length) {
//               for (var item in newTranslationItems) {
//                 if (curTranslationItems.indexWhere((element) => element.substring(0, element.indexOf(':')) == item.substring(0, item.indexOf(':'))) == -1) {
//                   curTranslationItems.insert(newTranslationItems.indexOf(item), item);
//                 }
//               }
//               String finalTranslation = curTranslationItems.join('",');
//               finalTranslation = finalTranslation.padLeft(finalTranslation.length + 1, '[{');
//               if (curLastItem == curTranslationItems.last) {
//                 finalTranslation = finalTranslation.padRight(finalTranslation.length + 1, '"}]');
//               } else {
//                 finalTranslation = finalTranslation.padRight(finalTranslation.length + 1, '}]');
//               }
//               File(lang.langFilePath).writeAsStringSync(finalTranslation);
//             }
//           }
//         }
//       }
//     }
//   }

// Future<TranslationText> getUITextTranslation() async {
//     if (languageList.isEmpty) {
//       var jsonData = jsonDecode(File(modsListJsonPath.toFilePath()).readAsStringSync());
//   var jsonCategories = [];
//   for (var cate in jsonData) {
//     jsonCategories.add(Category.fromJson(cate));
//   }
//       for (var lang in langList) {
//         langDropDownList.add(lang.langInitial);
//         if (lang.langFilePath != '$curLanguageDirPath$s${lang.langInitial}.json') {
//           lang.langFilePath = '$curLanguageDirPath$s${lang.langInitial}.json';
//           //Json Write
//           langList.map((translation) => translation.toJson()).toList();
//           File(langSettingsPath).writeAsStringSync(json.encode(langList));
//         }
//         if (lang.selected) {
//           langDropDownSelected = lang.langInitial;
//           curSelectedLangPath = '$curLanguageDirPath$s${lang.langInitial}.json';
//           curActiveLang = lang.langInitial;
//         }
//       }
//     }

//     if (curLangText == null) {
//       curLangText = TranslationText.fromJson(jsonDecode(File(modsListJsonPath.toFilePath()).readAsStringSync()))
//       convertLangTextData(jsonDecode(File(curSelectedLangPath).readAsStringSync()));
//       //await Future.delayed(const Duration(milliseconds: 500));
//       setState(() {});
//     }

//     topBtnMenuItems = [curLangText!.modsFolderBtnText, curLangText!.backupFolderBtnText, curLangText!.deletedItemsBtnText];
//   }

//Language Loader
Future<List<TranslationLanguage>> translationLoader() async {
  List<TranslationLanguage> langList = [];
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      TranslationLanguage translation = TranslationLanguage(
        b['langInitial'],
        b['langFilePath'],
        b['selected'],
      );
      langList.add(translation);
    }
  }

  if (langList.isEmpty && File(langSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(File(langSettingsPath).readAsStringSync()));
  }

  return langList;
}
