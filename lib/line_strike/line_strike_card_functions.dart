import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_element_popup.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> lineStrikeStatus = Signal('');

Future<List<LineStrikeCard>> lineStrikeCardsFetch() async {
  //Load list from json
  List<LineStrikeCard> cardData = [];
  if (File(mainLineStrikeCardListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(mainLineStrikeCardListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      cardData.add(LineStrikeCard.fromJson(type));
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  //Load vg from playerItemdata
  List<ItemData> csvCardZeroData = pItemData
      .where(
          (element) => element.csvFileName == 'Line Duel Cards.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'IcePath').value).characters.last == '0')
      .toList();
  List<ItemData> csvCardOneData = pItemData
      .where(
          (element) => element.csvFileName == 'Line Duel Cards.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'IcePath').value).characters.last == '1')
      .toList();
  List<ItemData> csvCardZeroIconData = pItemData
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value).characters.last == '0')
      .toList();
  List<ItemData> csvCardOneIconData = pItemData
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value).characters.last == '1')
      .toList();

  for (var data in csvCardZeroData.where((e) => cardData.indexWhere((c) => e.iconImagePath.contains(c.cardZeroDdsName)) == -1)) {
    await Future.delayed(const Duration(milliseconds: 50));
    ItemData cardZeroIconData = csvCardZeroIconData.firstWhere((e) => e.iconImagePath.contains(p.basenameWithoutExtension(data.iconImagePath).replaceFirst('card', 'icon')));
    String cardOneString = p.basenameWithoutExtension(data.iconImagePath).replaceRange(p.basenameWithoutExtension(data.iconImagePath).length - 1, null, '1');
    ItemData cardOneData = csvCardOneData.firstWhere((e) => e.iconImagePath.contains(cardOneString));
    ItemData cardOneIconData = csvCardOneIconData.firstWhere((e) => e.iconImagePath.contains(cardOneString.replaceFirst('card', 'icon')));

    //card0
    String cardZeroIcePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData.firstWhere((e) => e.path.contains(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last)).path.replaceAll('/', p.separator));
    String cardZeroIconIcePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData
            .firstWhere((e) => e.path.contains(cardZeroIconData.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last))
            .path
            .replaceAll('/', p.separator));
    String cardZeroDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String cardZeroIconDdsName = p.basenameWithoutExtension(cardZeroIconData.infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
    String cardZeroIconWebPath = '$githubIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
    String cardZeroSquareIconWebPath = '$githubIconDatabaseLink${cardZeroIconData.iconImagePath.replaceAll('\\', '/')}';

    //card1
    String cardOneIcePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData.firstWhere((e) => e.path.contains(cardOneData.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last)).path.replaceAll('/', p.separator));
    String cardOneIconIcePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData
            .firstWhere((e) => e.path.contains(cardOneIconData.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last))
            .path
            .replaceAll('/', p.separator));
    String cardOneDdsName = p.basenameWithoutExtension(cardOneData.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String cardOneIconDdsName = p.basenameWithoutExtension(cardOneIconData.infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
    String cardOneIconWebPath = '$githubIconDatabaseLink${cardOneData.iconImagePath.replaceAll('\\', '/')}';
    String cardOneSquareIconWebPath = '$githubIconDatabaseLink${cardOneIconData.iconImagePath.replaceAll('\\', '/')}';
    await Future.delayed(const Duration(milliseconds: 50));
    cardData.add(LineStrikeCard(cardZeroIcePath, cardZeroIconIcePath, cardZeroDdsName, cardZeroIconDdsName, cardZeroIconWebPath, cardZeroSquareIconWebPath, '', '', cardOneIcePath, cardOneIconIcePath,
        cardOneDdsName, cardOneIconDdsName, cardOneIconWebPath, cardOneSquareIconWebPath, '', '', '', false));
  }

  saveMasterLineStrikeCardListToJson(cardData);

  return cardData;
}

Future<List<File>> customCardImagesFetch() async {
  List<File> returnList = [];
  returnList = Directory(lineStrikeCardsDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
  return returnList;
}

void saveMasterLineStrikeCardListToJson(List<LineStrikeCard> cardList) {
  //Save to json
  cardList.map((card) => card.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainLineStrikeCardListJsonPath).writeAsStringSync(encoder.convert(cardList));
}

Future<bool> customImageApply(context, String imgPath, LineStrikeCard cardDataFile) async {
  if (Directory(lineStrikeCardTempDirPath).existsSync()) {
    Directory(lineStrikeCardTempDirPath).deleteSync(recursive: true);
    Directory(lineStrikeCardTempDirPath).createSync(recursive: true);
  } else {
    Directory(lineStrikeCardTempDirPath).createSync(recursive: true);
  }

  //prep image
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedIconImage = img.copyResize(replaceImage!, width: 104, height: 104);

  //download and replace
  //card zero replacement
  String cardZeroImageHash = '';
  File? replacedCardZeroIce;
  String newCardZeroTempIcePath = Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardZeroIcePath)}/group2').toFilePath();
  Directory(newCardZeroTempIcePath).createSync(recursive: true);
  if (Directory(newCardZeroTempIcePath).existsSync()) {
    final response = await http.get(Uri.parse(cardDataFile.cardZeroIconWebPath));

    if (response.statusCode == 200) {
      File originalCard = await File('$newCardZeroTempIcePath${p.separator}${p.basename(cardDataFile.cardZeroIconWebPath)}').writeAsBytes(response.bodyBytes);
      cardZeroImageHash = await originalCard.getMd5Hash();
      replacedCardZeroIce = await cardArtReplace(
          context, replaceImage, cardDataFile.cardZeroIcePath, cardDataFile.cardZeroDdsName, Uri.file('$newCardZeroTempIcePath/${p.basename(cardDataFile.cardZeroIconWebPath)}').toFilePath());

      if (replacedCardZeroIce != null && replacedCardZeroIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copiedFile = replacedCardZeroIce.copySync(cardDataFile.cardZeroIcePath);
            //cache
            String cachePath = cardDataFile.cardZeroIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardZeroIce.copySync(cachePath);
            cardDataFile.cardZeroReplacedIceMd5 = await copiedFile.getMd5Hash();
            i = 10;
          } catch (e) {
            i++;
          }
        }
        if (i > 10) {
          lineStrikeStatus.value = appText.failedToReplaceCard;
          Future.delayed(const Duration(microseconds: 10));
          return false;
        }
      }

      if (replacedCardZeroIce == null) return false;
    }
  }

  //card one replacement
  String newCardOneTempIcePath = Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardOneIcePath)}/group2').toFilePath();
  Directory(newCardOneTempIcePath).createSync(recursive: true);
  if (Directory(newCardOneTempIcePath).existsSync()) {
    final response = await http.get(Uri.parse(cardDataFile.cardOneIconWebPath));
    if (response.statusCode == 200) {
      File originalCard = await File(Uri.file('$newCardOneTempIcePath/${p.basename(cardDataFile.cardOneIconWebPath)}').toFilePath()).writeAsBytes(response.bodyBytes);
      File? replacedCardOneIce;
      if (cardZeroImageHash != await originalCard.getMd5Hash()) {
        replacedCardOneIce = await cardArtReplace(
            context, replaceImage, cardDataFile.cardOneIcePath, cardDataFile.cardOneDdsName, Uri.file('$newCardOneTempIcePath/${p.basename(cardDataFile.cardOneIconWebPath)}').toFilePath());
      } else {
        await Directory(Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardOneIcePath)}').toFilePath()).delete(recursive: true);
        replacedCardOneIce = await replacedCardZeroIce!.copy(replacedCardZeroIce.path.replaceFirst(p.basename(cardDataFile.cardOneIcePath), cardDataFile.cardOneIcePath));
      }
      if (replacedCardOneIce != null && replacedCardOneIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copiedFile = replacedCardOneIce.copySync(cardDataFile.cardOneIcePath);
            //cache
            String cachePath = cardDataFile.cardOneIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardOneIce.copySync(cachePath);
            cardDataFile.cardOneReplacedIceMd5 = await copiedFile.getMd5Hash();
            i = 10;
          } catch (e) {
            i++;
          }
        }
        if (i > 10) {
          lineStrikeStatus.value = appText.failedToReplaceCard;
          return false;
        }
      }

      if (replacedCardOneIce == null) return false;
    }
  }

  //icon zero replacement
  String cardZeroIconImageHash = '';
  File? replacedCardZeroIconIce;
  String newCardZeroTempIconIcePath = Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardZeroIconIcePath)}/group2').toFilePath();
  Directory(newCardZeroTempIconIcePath).createSync(recursive: true);

  if (Directory(newCardZeroTempIconIcePath).existsSync()) {
    final response = await http.get(Uri.parse(cardDataFile.cardZeroSquareIconWebPath));

    if (response.statusCode == 200) {
      File originalCardIcon = await File(Uri.file('$newCardZeroTempIconIcePath/${p.basename(cardDataFile.cardZeroSquareIconWebPath)}').toFilePath()).writeAsBytes(response.bodyBytes);
      cardZeroIconImageHash = await originalCardIcon.getMd5Hash();
      replacedCardZeroIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardZeroIconIcePath, cardDataFile.cardZeroIconDdsName,
          Uri.file('$newCardZeroTempIconIcePath/${p.basename(cardDataFile.cardZeroSquareIconWebPath)}').toFilePath());
      if (replacedCardZeroIconIce != null && replacedCardZeroIconIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copiedFile = replacedCardZeroIconIce.copySync(cardDataFile.cardZeroIconIcePath);
            //cache
            String cachePath = cardDataFile.cardZeroIconIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardZeroIconIce.copySync(cachePath);
            cardDataFile.cardZeroReplacedIconIceMd5 = await copiedFile.getMd5Hash();
            i = 10;
          } catch (e) {
            i++;
          }
        }
        if (i > 10) {
          lineStrikeStatus.value = appText.failedToReplaceCardIcon;
          return false;
        }
      }
    }
  }

  //icon one replacement
  String newCardOneTempIconIcePath = Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardOneIconIcePath)}/group2').toFilePath();
  Directory(newCardOneTempIconIcePath).createSync(recursive: true);

  if (Directory(newCardOneTempIconIcePath).existsSync()) {
    final response = await http.get(Uri.parse(cardDataFile.cardOneSquareIconWebPath));
    if (response.statusCode == 200) {
      File originalCardIcon = await File(Uri.file('$newCardOneTempIconIcePath/${p.basename(cardDataFile.cardOneSquareIconWebPath)}').toFilePath()).writeAsBytes(response.bodyBytes);
      File? replacedCardOneIconIce;
      if (cardZeroIconImageHash != await originalCardIcon.getMd5Hash()) {
        replacedCardOneIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardOneIconIcePath, cardDataFile.cardOneIconDdsName, cardDataFile.cardOneSquareIconWebPath);
      } else {
        await Directory(Uri.file('$lineStrikeCardTempDirPath/${p.basename(cardDataFile.cardOneIconIcePath)}').toFilePath()).delete(recursive: true);
        replacedCardOneIconIce = await replacedCardZeroIconIce!.copy(replacedCardZeroIconIce.path.replaceFirst(p.basename(cardDataFile.cardOneIconIcePath), cardDataFile.cardOneIconIcePath));
      }
      if (replacedCardOneIconIce != null && replacedCardOneIconIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copiedFile = replacedCardOneIconIce.copySync(cardDataFile.cardOneIconIcePath);
            //cache
            String cachePath = cardDataFile.cardOneIconIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardOneIconIce.copySync(cachePath);
            cardDataFile.cardOneReplacedIconIceMd5 = await copiedFile.getMd5Hash();
            i = 10;
          } catch (e) {
            i++;
          }
        }
        if (i > 10) {
          lineStrikeStatus.value = appText.failedToReplaceCardIcon;
          return false;
        }
      }
    }
  }

  return true;
}

Future<File?> cardArtReplace(context, img.Image? replaceImage, String icePath, String ddsName, String downloadedIconWebPath) async {
  int cardElement = -1;
  if (File(downloadedIconWebPath).existsSync()) {
    //edit
    img.Image? ogCard = await img.decodePngFile(downloadedIconWebPath);
    img.Image? frameTemplate;
    img.Image? cardTemplate;

    // debugPrint('x: ' +
    //     ogCard!.getPixel(344, 380).x.toString() +
    //     ' | y: ' +
    //     ogCard.getPixel(344, 380).y.toString() +
    //     ' | r: ' +
    //     ogCard.getPixel(344, 380).r.toString() +
    //     ' | g: ' +
    //     ogCard.getPixel(344, 380).g.toString() +
    //     ' | b: ' +
    //     ogCard.getPixel(344, 380).b.toString() +
    //     " | a: " +
    //     ogCard.getPixel(344, 380).a.toString());

    if ((ogCard!.getPixel(344, 450).r == 92 && ogCard.getPixel(344, 450).g == 124 && ogCard.getPixel(344, 450).b == 204 && ogCard.getPixel(344, 450).a == 255) ||
        (ogCard.getPixel(344, 380).r == 184 && ogCard.getPixel(344, 380).g == 100 && ogCard.getPixel(344, 380).b == 100 && ogCard.getPixel(344, 380).a == 255)) {
      if (kDebugMode) {
        cardTemplate = await img.decodePngFile('assets/img/line_strike_card_template.png');
      } else {
        cardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_template.png').toFilePath());
      }
    } else {
      if (kDebugMode) {
        cardTemplate = await img.decodePngFile('assets/img/line_strike_card_template1.png');
      } else {
        cardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_template1.png').toFilePath());
      }
    }

    // img.Pixel ogCardCheckPixel = ogCard!.getPixel(31, 19);
    if (ogCard.getPixel(31, 19).r == 255 && ogCard.getPixel(31, 19).g == 99 && ogCard.getPixel(31, 19).b == 99 && ogCard.getPixel(31, 19).a == 255) {
      //fire
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_fire_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_fire_frame0_template.png').toFilePath());
      }
    } else if (ogCard.getPixel(31, 13).r == 120 && ogCard.getPixel(31, 13).g == 214 && ogCard.getPixel(31, 13).b == 253 && ogCard.getPixel(31, 13).a == 255) {
      //ice
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_ice_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_ice_frame0_template.png').toFilePath());
      }
    } else if (ogCard.getPixel(31, 13).r == 156 && ogCard.getPixel(31, 13).g == 255 && ogCard.getPixel(31, 13).b == 173 && ogCard.getPixel(31, 13).a == 255) {
      //wind
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_wind_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_wind_frame0_template.png').toFilePath());
      }
    } else if (ogCard.getPixel(35, 16).r == 255 && ogCard.getPixel(35, 16).g == 253 && ogCard.getPixel(35, 16).b == 97 && ogCard.getPixel(35, 16).a == 255) {
      //lightning
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_lightning_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_lightning_frame0_template.png').toFilePath());
      }
    } else if (ogCard.getPixel(26, 15).r == 255 && ogCard.getPixel(26, 15).g == 251 && ogCard.getPixel(26, 15).b == 239 && ogCard.getPixel(26, 15).a == 255) {
      //light
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_light_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_light_frame0_template.png').toFilePath());
      }
    } else if (ogCard.getPixel(24, 14).r == 255 && ogCard.getPixel(24, 14).g == 159 && ogCard.getPixel(24, 14).b == 255 && ogCard.getPixel(24, 14).a == 255) {
      //dark
      if (kDebugMode) {
        frameTemplate = await img.decodePngFile('assets/img/line_strike_card_dark_frame0_template.png');
      } else {
        frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_dark_frame0_template.png').toFilePath());
      }
    } else {
      if (cardElement == -1) {
        cardElement = await lineStrikeCardElementSelectPopup(context);
      }
      if (cardElement == 0) {
        //dark
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_dark_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_dark_frame0_template.png').toFilePath());
        }
      } else if (cardElement == 1) {
        //fire
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_fire_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_fire_frame0_template.png').toFilePath());
        }
      } else if (cardElement == 2) {
        //ice
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_ice_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_ice_frame0_template.png').toFilePath());
        }
      } else if (cardElement == 3) {
        //light
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_light_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_light_frame0_template.png').toFilePath());
        }
      } else if (cardElement == 4) {
        //lightning
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_lightning_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_lightning_frame0_template.png').toFilePath());
        }
      } else if (cardElement == 5) {
        //wind
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_wind_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_wind_frame0_template.png').toFilePath());
        }
      } else {
        cardElement = -1;
        return null;
      }
    }
    // else {
    //   for (var pixel in ogCard.data!) {
    //     if (pixel.x == 24 && pixel.y == 14) {
    //       debugPrint('x: ' +
    //           pixel.x.toString() +
    //           ' | y: ' +
    //           pixel.y.toString() +
    //           ' | r: ' +
    //           pixel.r.toString() +
    //           ' | g: ' +
    //           pixel.g.toString() +
    //           ' | b: ' +
    //           pixel.b.toString() +
    //           " | a: " +
    //           pixel.a.toString());
    //       break;
    //     }
    //   }
    // }

    for (var pixel in frameTemplate!.data!) {
      if (pixel.a > 0) ogCard.setPixel(pixel.x, pixel.y, pixel);
    }

    for (var templatePixel in cardTemplate!.data!) {
      if (templatePixel.a > 0) {
        try {
          ogCard.setPixel(templatePixel.x, templatePixel.y, replaceImage!.getPixel(templatePixel.x - 13, templatePixel.y - 16));
        } catch (e) {
          break;
        }
      }
    }

    await File(Uri.file(downloadedIconWebPath).toFilePath()).writeAsBytes(img.encodePng(ogCard));

    await Process.run(pngDdsConvExePath, [Uri.file(downloadedIconWebPath).toFilePath(), Uri.file('${File(downloadedIconWebPath).parent.path}/$ddsName.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file(downloadedIconWebPath).toFilePath()).delete();

    if (File(Uri.file('${File(downloadedIconWebPath).parent.path}/$ddsName.dds').toFilePath()).existsSync()) {
      await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeCardTempDirPath"', [Uri.file('$lineStrikeCardTempDirPath/${p.basename(icePath)}').toFilePath()]);
      Directory(Uri.file('$lineStrikeCardTempDirPath/${p.basename(icePath)}').toFilePath()).deleteSync(recursive: true);

      File renamedFile = await File(Uri.file('$lineStrikeCardTempDirPath/${p.basename(icePath)}.ice').toFilePath()).rename(Uri.file('$lineStrikeCardTempDirPath/${p.basename(icePath)}').toFilePath());
      return renamedFile;
    }
  }

  cardElement = -1;
  return null;
}

Future<File?> cardIconArtReplace(img.Image? resizedIconImage, String iconIcePath, String iconDdsName, String downloadedSquareIconWebPath) async {
  if (iconIcePath.isNotEmpty) {
    if (File(downloadedSquareIconWebPath).existsSync()) {
      img.Image? ogCardIcon = await img.decodePngFile(Uri.file(downloadedSquareIconWebPath).toFilePath());
      img.Image? iconTemplate;
      if (kDebugMode) {
        iconTemplate = await img.decodePngFile('assets/img/line_strike_card_icon_template.png');
      } else {
        iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_icon_template.png').toFilePath());
      }

      for (var templatePixel in iconTemplate!.data!) {
        if (templatePixel.a > 0) {
          try {
            ogCardIcon!.setPixel(templatePixel.x, templatePixel.y, resizedIconImage!.getPixel(templatePixel.x - 11, templatePixel.y - 11));
          } catch (e) {
            break;
          }
        }
      }

      await File(Uri.file(downloadedSquareIconWebPath).toFilePath()).writeAsBytes(img.encodePng(ogCardIcon!));

      await Process.run(pngDdsConvExePath,
          [Uri.file(downloadedSquareIconWebPath).toFilePath(), Uri.file(downloadedSquareIconWebPath.replaceFirst(p.extension(downloadedSquareIconWebPath), '.dds')).toFilePath(), '-pngtodds']);
      await File(Uri.file(downloadedSquareIconWebPath).toFilePath()).delete();
    }

    if (File(Uri.file(downloadedSquareIconWebPath.replaceFirst(p.extension(downloadedSquareIconWebPath), '.dds')).toFilePath()).existsSync()) {
      await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeCardTempDirPath"', [Uri.file('$lineStrikeCardTempDirPath/${p.basename(iconIcePath)}').toFilePath()]);
      Directory(Uri.file('$lineStrikeCardTempDirPath/${p.basename(iconIcePath)}').toFilePath()).deleteSync(recursive: true);

      File renamedFile =
          await File(Uri.file('$lineStrikeCardTempDirPath/${p.basename(iconIcePath)}.ice').toFilePath()).rename(Uri.file('$lineStrikeCardTempDirPath/${p.basename(iconIcePath)}').toFilePath());
      return renamedFile;
    }
  }
  return null;
}