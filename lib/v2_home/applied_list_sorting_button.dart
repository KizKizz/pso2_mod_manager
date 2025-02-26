import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/choice_anchor_layout.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class AppliedListSortingButton extends StatefulWidget {
  const AppliedListSortingButton({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<AppliedListSortingButton> createState() => _AppliedListSortingButtonState();
}

class _AppliedListSortingButtonState extends State<AppliedListSortingButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: PromptedChoice<String>.single(
        title: appText.sort,
        value: appText.sortingTypeName(selectedDisplaySortAppliedList.value),
        modalFit: FlexFit.tight,
        onChanged: (value) async {
          final prefs = await SharedPreferences.getInstance();
          selectedDisplaySortAppliedList.value = value!;
          prefs.setString('selectedDisplaySortAppliedList', selectedDisplaySortAppliedList.value);
          widget.scrollController.jumpTo(0);
        },
        itemCount: modSortingSelections.length,
        itemBuilder: (state, i) {
          return RadioListTile(
            value: modSortingSelections[i],
            groupValue: state.single,
            onChanged: (value) {
              state.select(modSortingSelections[i]);
            },
            title: ChoiceText(
              appText.sortingTypeName(modSortingSelections[i]),
              highlight: state.search?.value,
              style: TextStyle(color: selectedDisplaySortAppliedList.watch(context) == modSortingSelections[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
            ),
          );
        },
        promptDelegate: ChoicePrompt.delegateBottomSheet(),
        anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)
      ),
    );
  }
}