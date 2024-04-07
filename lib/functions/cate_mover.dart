
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<void> categoryMover(context, CategoryType curCateType, Category cateToMove) async {
  CategoryType selectedType = moddedItemsList.firstWhere((element) => element.groupName != curCateType.groupName);
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            List<CategoryType> possibleCateType = moddedItemsList.where((element) => element.groupName != cateToMove.group).toList();
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiMovingCategory, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('${curLangText!.uiSelectACategoryGroupBelowToMove} "${cateToMove.categoryName}"'),
                      ),
                      ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                              }
                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                            }),
                          ),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              for (int i = 0; i < possibleCateType.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                                  child: RadioListTile(
                                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                    value: possibleCateType[i],
                                    groupValue: selectedType,
                                    title: Text(possibleCateType[i].groupName),
                                    subtitle:
                                        Text(possibleCateType[i].categories.length < 2 ? '${possibleCateType[i].categories.length} ${curLangText!.uiCategory}' : '${possibleCateType[i].categories.length} ${curLangText!.uiCategories}'),
                                    onChanged: (CategoryType? currentType) {
                                      //print("Current ${moddedItemsList[i].groupName}");
                                      selectedType = currentType!;
                                      setState(
                                        () {},
                                      );
                                    },
                                    //selected: true,
                                  ),
                                ),
                            ],
                          )))
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: () async {
                        selectedType.categories.insert(0, cateToMove);
                        cateToMove.group = selectedType.groupName;
                        for (var cate in selectedType.categories) {
                          cate.position = selectedType.categories.indexOf(cate);
                        }
                        curCateType.categories.remove(cateToMove);
                        for (var cate in curCateType.categories) {
                          cate.position = curCateType.categories.indexOf(cate);
                        }
                        appliedItemList = await appliedListBuilder(moddedItemsList);
                        saveModdedItemListToJson();
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: Text(curLangText!.uiMove))
                ]);
          }));
}
