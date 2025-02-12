import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class AppliedModCategorySelectButtons extends StatefulWidget {
  const AppliedModCategorySelectButtons({super.key, required this.categories, required this.scrollController});

  final List<Category> categories;
  final ScrollController scrollController;

  @override
  State<AppliedModCategorySelectButtons> createState() => _AppliedModCategorySelectButtonsState();
}

class _AppliedModCategorySelectButtonsState extends State<AppliedModCategorySelectButtons> {
  late List<String> categoryNames;
  List<int> cateItemAmount = [];

  @override
  void initState() {
    categoryNames = widget.categories.map((e) => e.categoryName).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cateItemAmount = widget.categories.map((e) => e.getNumOfAppliedItems()).toList();
    if (!categoryNames.contains('All')) {
      categoryNames.insert(0, 'All');
      int totalItems = 0;
      for (var count in cateItemAmount) {
        totalItems += count;
      }
      cateItemAmount.insert(0, totalItems);
    } else {
      int totalItems = 0;
      for (var count in cateItemAmount) {
        totalItems += count;
      }
      cateItemAmount.insert(0, totalItems);
    }

    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.view,
          value: appText.categoryName(selectedDisplayCategoryAppliedList.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            selectedDisplayCategoryAppliedList.value = value!;
            prefs.setString('selectedDisplayCategoryAppliedList', selectedDisplayCategoryAppliedList.value);
            widget.scrollController.jumpTo(0);
          },
          itemCount: categoryNames.length,
          itemBuilder: (state, i) {
            return RadioListTile(
                value: appText.categoryName(categoryNames[i]),
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
                      style: TextStyle(
                          color: selectedDisplayCategoryAppliedList.watch(context) == categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    HeaderInfoBox(info: appText.dText(cateItemAmount[i] > 1 ? appText.numItems : appText.numItem, cateItemAmount[i].toString()), borderHighlight: false)
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
