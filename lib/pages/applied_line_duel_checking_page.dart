import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/line_strike_board_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_card_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/line_duel/applied_line_duel_check.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';
import 'package:window_manager/window_manager.dart';

class AppliedLineDuelCheckingPage extends StatefulWidget {
  const AppliedLineDuelCheckingPage({super.key});

  @override
  State<AppliedLineDuelCheckingPage> createState() => _AppliedLineDuelCheckingPageState();
}

class _AppliedLineDuelCheckingPageState extends State<AppliedLineDuelCheckingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: appliedLineDuelCheck(context),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curLangText!.uiCheckingLineStrikeItems,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(),
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
                      curLangText!.uiErrorWhenCheckingLineStrikeItems,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          windowManager.destroy();
                        },
                        child: Text(curLangText!.uiExit))
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiCheckingLineStrikeItems,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              //Return
              (List<LineStrikeBoard>, List<LineStrikeCard>, List<LineStrikeSleeve>) result = snapshot.data;
              var (replacedBoards, replacedCards, replacedSleeves) = result;
              if (result.$1.isNotEmpty || result.$2.isNotEmpty || result.$3.isNotEmpty) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Text(
                            '${curLangText!.uiReappliedLineStrikeItems}:',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Column(children: [
                            Text('${curLangText!.uiCustomBoardImages}: ${replacedBoards.length},', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                            Text('${curLangText!.uiCustomCardImages}: ${replacedCards.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                            Text('${curLangText!.uiCustomCardSleeveImages}: ${replacedSleeves.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400))
                          ],)
                        ),

                        //button
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                const ModSetsLoadingPage();
                                setState(() {});
                              },
                              child: Text(curLangText!.uiGotIt)),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const ModSetsLoadingPage();
              }
            }
          }
        });
  }
}
