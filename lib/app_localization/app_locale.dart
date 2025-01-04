import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';

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
      for (var locale in jsonDecode(localeSettingsFile.readAsStringSync())) {
        final appLocale = AppLocale.fromJson(locale);
        if (File(appLocale.translationFilePath).existsSync()) localeList.add(appLocale);
      }
    }

    return localeList;
  }

  Future<void> localeInit() async {
    List<AppLocale> localLocales = [];
    if (localeSettingsFile.existsSync()) {
      var jsonData = jsonDecode(localeSettingsFile.readAsStringSync());
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
    }

    if (localLocales.isEmpty || localLocales.indexWhere((e) => e.language == 'EN') == -1) {
      AppLocale newLocale = AppLocale().createLocale('EN', 1, true);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      await File(newLocale.translationFilePath).writeAsString(encoder.convert(AppText()));
      localLocales.add(newLocale);
      appText = AppText.fromJson(jsonDecode(File(newLocale.translationFilePath).readAsStringSync()));
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
      // Update local from remote
      for (var locale in locales) {
        int remoteLocaleIndex = remoteLocales.indexWhere((e) => e.language == locale.language);
        if (remoteLocaleIndex != -1 && remoteLocales[remoteLocaleIndex].version > locale.version) {
          final tResponse = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/Locale/${remoteLocales[remoteLocaleIndex]}.json'));
          if (tResponse.statusCode == 200) {
            File(locale.translationFilePath).writeAsStringSync(tResponse.body);
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
    }

    saveSettings(locales);
  }
}
