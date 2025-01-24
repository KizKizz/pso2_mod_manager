import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
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
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.view,
          value: appText.categoryName(selectedDisplayCategory.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            selectedDisplayCategory.value = value!;
            prefs.setString('selectedDisplayCategory', selectedDisplayCategory.value);
            widget.scrollController.jumpTo(0);
          },
          itemCount: categoryNames.length,
          itemBuilder: (state, i) {
            return RadioListTile(
                value: categoryNames[i],
                groupValue: state.single,
                onChanged: (value) {
                  state.select(categoryNames[i]);
                },
                title: Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChoiceText(
                      appText.categoryName(categoryNames[i]),
                      highlight: state.search?.value,
                      style: TextStyle(color: selectedDisplayCategory.watch(context) == categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
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

class ChoiceAnchorLayout extends StatelessWidget {
  const ChoiceAnchorLayout({super.key, required this.state, required this.openModal});

  final ChoiceController<String> state;
  final Function() openModal;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(50))),
          tileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 2),
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.labelLarge!.color),
          minTileHeight: 35,
          minVerticalPadding: 0,
          leadingAndTrailingTextStyle: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.labelLarge!.color)),
      child: ChoiceAnchor.create(
        valueTruncate: 2,
        inline: true,
      )(state, openModal),
    );
  }
}
