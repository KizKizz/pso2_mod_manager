import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedQuickSwapTypeCategory = Signal<String>(appText.both);

class QuickSwapTypeSelectButtons extends StatefulWidget {
  const QuickSwapTypeSelectButtons({super.key, required this.lScrollController, required this.rScrollController});

  final ScrollController lScrollController;
  final ScrollController rScrollController;

  @override
  State<QuickSwapTypeSelectButtons> createState() => _ItemSwapTypeSelectButtonsState();
}

class _ItemSwapTypeSelectButtonsState extends State<QuickSwapTypeSelectButtons> {
  final itemTypes = [appText.both, 'PSO2', 'NGS'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.types,
          value: appText.categoryName(selectedQuickSwapTypeCategory.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedQuickSwapTypeCategory.value = value!;
            widget.lScrollController.jumpTo(0);
            widget.rScrollController.jumpTo(0);
          },
          itemCount: itemTypes.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: itemTypes[i],
              groupValue: state.single,
              onChanged: (value) {
                state.select(itemTypes[i]);
              },
              title: ChoiceText(
                itemTypes[i],
                highlight: state.search?.value,
                style: TextStyle(color: selectedQuickSwapTypeCategory.watch(context) == itemTypes[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}
