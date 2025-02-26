import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/choice_anchor_layout.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class CateModCategorySelectButtons extends StatefulWidget {
  const CateModCategorySelectButtons({super.key, required this.categories, required this.scrollController});

  final List<Category> categories;
  final ScrollController scrollController;

  @override
  State<CateModCategorySelectButtons> createState() => _CateModCategorySelectButtonsState();
}

class _CateModCategorySelectButtonsState extends State<CateModCategorySelectButtons> {
  late List<String> categoryNames;
  List<int> cateModAmount = [];

  @override
  void initState() {
    categoryNames = widget.categories.map((e) => e.categoryName).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cateModAmount = [];
    for (var cate in widget.categories) {
      int curAmount = 0;
      for (var item in cate.items) {
        curAmount += item.mods.length;
      }
      cateModAmount.add(curAmount);
    }
    if (!categoryNames.contains('All')) {
      categoryNames.insert(0, 'All');
      int totalItems = 0;
      for (var count in cateModAmount) {
        totalItems += count;
      }
      cateModAmount.insert(0, totalItems);
    } else {
      int totalItems = 0;
      for (var count in cateModAmount) {
        totalItems += count;
      }
      cateModAmount.insert(0, totalItems);
    }

    return SizedBox(
      height: 30,
      child: PromptedChoice<String>.single(
          title: appText.view,
          value: appText.categoryName(selectedModDisplayCategory.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            selectedModDisplayCategory.value = value!;
            prefs.setString('selectedModDisplayCategory', selectedModDisplayCategory.value);
            widget.scrollController.jumpTo(0);
          },
          itemCount: categoryNames.length,
          itemBuilder: (state, i) {
            return RadioListTile(
                value: appText.categoryName(categoryNames[i]),
                groupValue: state.single,
                onChanged: (value) {
                  state.select(categoryNames[i]);
                  debugPrint(state.value.toString());
                },
                title: Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChoiceText(
                      appText.categoryName(categoryNames[i]),
                      highlight: state.search?.value,
                      style: TextStyle(color: selectedModDisplayCategory.watch(context) == categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    HeaderInfoBox(info: appText.dText(cateModAmount[i] > 1 ? appText.numMods : appText.numMod, cateModAmount[i].toString()), borderHighlight: false)
                  ],
                ));
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}
