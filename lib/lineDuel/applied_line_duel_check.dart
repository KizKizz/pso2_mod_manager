import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/line_strike_board_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_card_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/lineDuel/line_duel_boards_homepage.dart';
import 'package:pso2_mod_manager/lineDuel/line_duel_cards_homepage.dart';
import 'package:pso2_mod_manager/lineDuel/line_duel_sleeves_homepage.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<(List<LineStrikeBoard>, List<LineStrikeCard>, List<LineStrikeSleeve>)> appliedLineDuelCheck(context) async {
  List<LineStrikeBoard> reappliedBoards = [];
  List<LineStrikeCard> reappliedCards = [];
  List<LineStrikeSleeve> reappliedSleeves = [];
  //boards
  List<LineStrikeBoard> boardsInJson = [];
  if (File(modManLineStrikeBoardJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeBoardJsonPath).readAsStringSync());
    for (var type in jsonData) {
      boardsInJson.add(LineStrikeBoard.fromJson(type));
    }
  }
  for (var board in boardsInJson) {
    bool reApply = false;
    bool reApplied = false;
    if (board.isReplaced) {
      if (board.replacedIceMd5 != await getFileHash(board.icePath)) {
        String cachePath = board.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(board.icePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (board.replacedIconIceMd5 != await getFileHash(board.iconIcePath)) {
        String cachePath = board.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(board.iconIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (reApply) {
        await customBoardApply(context, board.replacedImagePath, board);
        reApplied = true;
      }
      if (reApplied) {
        reappliedBoards.add(board);
      }
    }
  }

  //sleeves
  List<LineStrikeSleeve> sleeveDataFromJson = [];
  if (File(modManLineStrikeSleeveJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeSleeveJsonPath).readAsStringSync());
    for (var type in jsonData) {
      sleeveDataFromJson.add(LineStrikeSleeve.fromJson(type));
    }
  }
  for (var sleeve in sleeveDataFromJson) {
    bool reApply = false;
    bool reApplied = false;
    if (sleeve.isReplaced) {
      if (sleeve.replacedIceMd5 != await getFileHash(sleeve.icePath)) {
        String cachePath = sleeve.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(sleeve.icePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (sleeve.replacedIconIceMd5 != await getFileHash(sleeve.iconIcePath)) {
        String cachePath = sleeve.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(sleeve.iconIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (reApply) {
        await customSleeveApply(context, sleeve.replacedImagePath, sleeve);
        reApplied = true;
      }
      if (reApplied) {
        reappliedSleeves.add(sleeve);
      }
    }
  }

  //cards
  List<LineStrikeCard> cardDataFromJson = [];
  if (File(modManLineStrikeCardJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeCardJsonPath).readAsStringSync());
    for (var type in jsonData) {
      cardDataFromJson.add(LineStrikeCard.fromJson(type));
    }
  }
  for (var card in cardDataFromJson) {
    bool reApply = false;
    bool reApplied = false;
    if (card.isReplaced) {
      if (card.cardZeroReplacedIceMd5 != await getFileHash(card.cardZeroIcePath)) {
        String cachePath = card.cardZeroIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(card.cardZeroIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (card.cardZeroReplacedIconIceMd5 != await getFileHash(card.cardZeroIconIcePath)) {
        String cachePath = card.cardZeroIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(card.cardZeroIconIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (card.cardOneReplacedIceMd5 != await getFileHash(card.cardOneIcePath)) {
        String cachePath = card.cardOneIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(card.cardOneIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (card.cardOneReplacedIconIceMd5 != await getFileHash(card.cardOneIconIcePath)) {
        String cachePath = card.cardOneIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
        if (File(cachePath).existsSync()) {
          File(cachePath).copySync(card.cardOneIconIcePath);
          reApplied = true;
        } else {
          reApply = true;
        }
      }
      if (reApply) {
        await customCardApply(context, card.replacedImagePath, card);
        reApplied = true;
      }
      if (reApplied) {
        reappliedCards.add(card);
      }
    }
  }

  return (reappliedBoards, reappliedCards, reappliedSleeves);
}
