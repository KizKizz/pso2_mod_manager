import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';

part 'app_locale.g.dart';

File localeSettingsFile = File('${Directory.current.path}${p.separator}Locale${p.separator}LocaleSettings.json');
const localeSettingsGitHubLink = 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/Locale/LocaleSettings.json';

@JsonSerializable()
class AppLocale {
  AppLocale();
  AppLocale.create(this.language, this.version, this.translationFilePath, this.isActive);

  String language = '';
  int version = 1;
  String translationFilePath = '';
  bool isActive = false;

  factory AppLocale.fromJson(Map<String, dynamic> json) => _$AppLocaleFromJson(json);
  Map<String, dynamic> toJson() => _$AppLocaleToJson(this);

  AppLocale createLocale(String languageInitial, int version, bool active) {
    File translationFile = File('${Directory.current.path}${p.separator}Locale${p.separator}$languageInitial.json');
    if (!translationFile.existsSync()) translationFile.createSync(recursive: true);

    return AppLocale.create(languageInitial, version, translationFile.path, active);
  }

  void saveSettings(List<AppLocale> localeList) {
    if (!localeSettingsFile.existsSync()) localeSettingsFile.createSync(recursive: true);
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    localeSettingsFile.writeAsStringSync(encoder.convert(localeList.map((list) => list.toJson()).toList()));
  }

  List<AppLocale> loadLocales() {
    List<AppLocale> localeList = [];
    if (localeSettingsFile.existsSync()) {
      var data = jsonDecode(localeSettingsFile.readAsStringSync());
      for (var locale in data) {
        final appLocale = AppLocale.fromJson(locale);
        if (File(appLocale.translationFilePath).existsSync()) localeList.add(appLocale);
      }
    }

    return localeList;
  }

  Future<void> localeInit() async {
    List<AppLocale> localLocales = [];
    if (localeSettingsFile.existsSync()) {
      var jsonData = jsonDecode(await localeSettingsFile.readAsString());
      for (var data in jsonData) {
        AppLocale appLocale = AppLocale.fromJson(data);
        if (File(appLocale.translationFilePath).existsSync()) {
          localLocales.add(appLocale);
        } else {
          File translationFile = File('${Directory.current.path}${p.separator}Locale${p.separator}${appLocale.language}.json');
          if (!translationFile.existsSync()) {
            translationFile.createSync();
          }
          appLocale.translationFilePath = translationFile.path;
          localLocales.add(appLocale);
        }
        if (localLocales.last.language == 'EN') {
          const JsonEncoder encoder = JsonEncoder.withIndent('  ');
          await File(localLocales.last.translationFilePath).writeAsString(encoder.convert(AppText()));
        }
      }

      if (localLocales.isEmpty || localLocales.indexWhere((e) => e.language == 'EN') == -1) {
        AppLocale newLocale = AppLocale().createLocale('EN', 1, true);
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        await File(newLocale.translationFilePath).writeAsString(encoder.convert(AppText()));
        localLocales.add(newLocale);
        appText = AppText.fromJson(jsonDecode(File(newLocale.translationFilePath).readAsStringSync()));
      }

      // Update other locale files
      final enLocale = localLocales[localLocales.indexWhere((e) => e.language == 'EN')];
      for (var locale in localLocales.where((e) => e.language != 'EN')) {
        List<String> enLocaleContent = File(enLocale.translationFilePath).readAsLinesSync();
        List<String> curLocaleContent = File(locale.translationFilePath).readAsLinesSync();
        enLocaleContent.removeWhere((e) => curLocaleContent.indexWhere((f) => f.contains(e.split('": "').first)) != -1);
        if (enLocaleContent.isNotEmpty) {
          if (curLocaleContent.isEmpty) {
            curLocaleContent = enLocaleContent;
          } else {
            if (!enLocaleContent.last.endsWith(',')) enLocaleContent.last = '${enLocaleContent.last},';
            curLocaleContent.insertAll(1, enLocaleContent);
          }
          await File(locale.translationFilePath).writeAsString(curLocaleContent.join('\n'));
        }
      }
    }

    saveSettings(localLocales);
  }

  Future<void> localeGet() async {
    List<AppLocale> locales = loadLocales();
    // Sync with remote
    final response = await http.get(Uri.parse(localeSettingsGitHubLink));
    if (response.statusCode == 200) {
      List<AppLocale> remoteLocales = [];
      for (var locale in jsonDecode(response.body)) {
        remoteLocales.add(AppLocale.fromJson(locale));
      }
      // Refresh translation file paths

      // Update local from remote
      for (var locale in locales) {
        int remoteLocaleIndex = remoteLocales.indexWhere((e) => e.language == locale.language);
        if (remoteLocaleIndex != -1 && remoteLocales[remoteLocaleIndex].version > locale.version) {
          final tResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/Locale/${remoteLocales[remoteLocaleIndex].language}.json'));
          if (tResponse.statusCode == 200) {
            await File(locale.translationFilePath).writeAsString(tResponse.body);
            locale.version = remoteLocales[remoteLocaleIndex].version;
          } else {
            throw Exception(appText.dText(appText.unableToUpdateFile, '${locale.language}.json'));
          }
        }
      }
      // Download missing translation from remote
      for (var locale in remoteLocales) {
        if (locales.indexWhere((e) => e.language == locale.language) == -1) {
          final tResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/Locale/${locale.language}.json'));
          if (tResponse.statusCode == 200) {
            File('${Directory.current.path}${p.separator}Locale${p.separator}${locale.language}.json').writeAsStringSync(tResponse.body);
            locales.add(AppLocale.create(locale.language, locale.version, '${Directory.current.path}${p.separator}Locale${p.separator}${locale.language}.json', false));
          } else {
            throw Exception(appText.dText(appText.unableToUpdateFile, '${locale.language}.json'));
          }
        }
      }
    } else {
      throw Exception(appText.failedToFetchRemoteLocaleData);
    }

    // Switch to default if none active
    if (locales.indexWhere((e) => e.isActive) == -1) {
      int defaultLocaleIndex = locales.indexWhere((e) => e.language == 'EN');
      if (defaultLocaleIndex != -1) {
        locales[defaultLocaleIndex].isActive = true;
        appText = AppText.fromJson(jsonDecode(File(locales[defaultLocaleIndex].translationFilePath).readAsStringSync()));
      } else {
        AppLocale newLocale = AppLocale().createLocale('EN', 1, true);
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        await File(newLocale.translationFilePath).writeAsString(encoder.convert(AppText()));
        locales.add(newLocale);
        appText = AppText.fromJson(jsonDecode(File(newLocale.translationFilePath).readAsStringSync()));
      }
    } else {
      appText = AppText.fromJson(jsonDecode(File(locales[locales.indexWhere((e) => e.isActive)].translationFilePath).readAsStringSync()));
    }

    saveSettings(locales);
  }

  Future<void> offlineLocaleGet() async {
    List<AppLocale> locales = loadLocales();

    // Switch to default if none active
    if (locales.indexWhere((e) => e.isActive) == -1) {
      int defaultLocaleIndex = locales.indexWhere((e) => e.language == 'EN');
      if (defaultLocaleIndex != -1) {
        locales[defaultLocaleIndex].isActive = true;
        appText = AppText.fromJson(jsonDecode(File(locales[defaultLocaleIndex].translationFilePath).readAsStringSync()));
      } else {
        AppLocale newLocale = AppLocale().createLocale('EN', 1, true);
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        await File(newLocale.translationFilePath).writeAsString(encoder.convert(AppText()));
        locales.add(newLocale);
        appText = AppText.fromJson(jsonDecode(File(newLocale.translationFilePath).readAsStringSync()));
      }
    } else {
      appText = AppText.fromJson(jsonDecode(File(locales[locales.indexWhere((e) => e.isActive)].translationFilePath).readAsStringSync()));
    }

    saveSettings(locales);
  }
}
