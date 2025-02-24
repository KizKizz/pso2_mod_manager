import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/choice_anchor_layout.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedQuickSwapTypeCategory = Signal<String>('Both');

class QuickSwapTypeSelectButtons extends StatefulWidget {
  const QuickSwapTypeSelectButtons({super.key, required this.lScrollController, required this.rScrollController});

  final ScrollController lScrollController;
  final ScrollController rScrollController;

  @override
  State<QuickSwapTypeSelectButtons> createState() => _ItemSwapTypeSelectButtonsState();
}

class _ItemSwapTypeSelectButtonsState extends State<QuickSwapTypeSelectButtons> {
  final itemTypes = ['Both', 'PSO2', 'NGS'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: PromptedChoice<String>.single(
          title: appText.types,
          value: selectedQuickSwapTypeCategory.value == itemTypes.first ? appText.both : selectedQuickSwapTypeCategory.value,
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedQuickSwapTypeCategory.value = value!;
            widget.lScrollController.jumpTo(0);
            widget.rScrollController.jumpTo(0);
          },
          itemCount: itemTypes.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: i == 0 ? appText.both : itemTypes[i],
              groupValue: state.single,
              onChanged: (value) {
                state.select(itemTypes[i]);
              },
              title: ChoiceText(
                i == 0 ? appText.both : itemTypes[i],
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
