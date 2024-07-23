import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/line_duel/line_duel_boards_homepage.dart';
import 'package:pso2_mod_manager/line_duel/line_duel_cards_homepage.dart';
import 'package:pso2_mod_manager/line_duel/line_duel_sleeves_homepage.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';


String? selectedType;

Future<void> lineDuelSelection(context) async {
  List<String> lineDuelSelections = [curLangText!.uiBoards, curLangText!.uiCards, curLangText!.uiCardSleeves];
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                title: Text(curLangText!.uiSelectACategory, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                content: SizedBox(
                  width: 200,
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    hint: Text(curLangText!.uiItemCategories),
                    buttonStyleData: ButtonStyleData(
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).hintColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: windowsHeight * 0.5,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    iconStyleData: const IconStyleData(iconSize: 15),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    isDense: true,
                    items: lineDuelSelections
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // if (curActiveLang != 'JP')
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          //fontSize: 14,
                                          //fontWeight: FontWeight.bold,
                                          //color: Colors.white,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                // if (curActiveLang != 'EN')
                                //   Container(
                                //     padding: const EdgeInsets.only(bottom: 3),
                                //     child: Text(
                                //       lineDuelSelections[lineDuelSelections.indexOf(item)],
                                //       style: const TextStyle(
                                //           //fontSize: 14,
                                //           //fontWeight: FontWeight.bold,
                                //           //color: Colors.white,
                                //           ),
                                //       overflow: TextOverflow.ellipsis,
                                //     ),
                                //   )
                              ],
                            )))
                        .toList(),
                    value: selectedType,
                    onChanged: (value) async {
                      selectedType = value.toString();

                      setState(() {});
                    },
                  )),
                ),
                actionsPadding: const EdgeInsets.all(10),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: selectedType == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              if (selectedType == lineDuelSelections[0]) {
                                lineDuelBoardsHomePage(context);
                              } else if (selectedType == lineDuelSelections[1]) {
                                lineDuelCardsHomePage(context);
                              } else if (selectedType == lineDuelSelections[2]) {
                                lineDuelSleevesHomePage(context);
                              }
                            },
                      child: Text(curLangText!.uiNext))
                ]);
          }));
}
