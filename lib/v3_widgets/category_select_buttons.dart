import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class CategorySelectButtons extends StatefulWidget {
  const CategorySelectButtons({super.key, required this.categoryNames, required this.scrollController});

  final List<String> categoryNames;
  final ScrollController scrollController;

  @override
  State<CategorySelectButtons> createState() => _CategorySelectButtonsState();
}

class _CategorySelectButtonsState extends State<CategorySelectButtons> {
  @override
  Widget build(BuildContext context) {
    if (!widget.categoryNames.contains('All')) widget.categoryNames.insert(0, 'All');
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
        title: appText.view,
        value: selectedDisplayCategory.value,
        modalFit: FlexFit.tight,
        onChanged: (value) async {
          final prefs = await SharedPreferences.getInstance();
          selectedDisplayCategory.value = value!;
          prefs.setString('selectedDisplayCategory', selectedDisplayCategory.value);
          widget.scrollController.jumpTo(0);
        },
        itemCount: widget.categoryNames.length,
        itemBuilder: (state, i) {
          return RadioListTile(
            value: widget.categoryNames[i],
            groupValue: state.single,
            onChanged: (value) {
              state.select(widget.categoryNames[i]);
            },
            title: ChoiceText(
              appText.categoryName(widget.categoryNames[i]),
              highlight: state.search?.value,
              style: TextStyle(color: selectedDisplayCategory.watch(context) == widget.categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
            ),
          );
        },
        promptDelegate: ChoicePrompt.delegateBottomSheet(),
        anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)
      ),
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
              titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              minTileHeight: 35,
              minVerticalPadding: 0,
              leadingAndTrailingTextStyle: const TextStyle(fontSize: 15)),
          child: ChoiceAnchor.create(
            valueTruncate: 2,
            inline: true,
          )(state, openModal),
        );
  }
}