import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedModSwapAllMotionType = Signal<String>('All');

class ModSwapAllMotionsSelectButton extends StatefulWidget {
  const ModSwapAllMotionsSelectButton({super.key, required this.rScrollController});

  final ScrollController rScrollController;

  @override
  State<ModSwapAllMotionsSelectButton> createState() => _ModSwapAllMotionsSelectButtonState();
}

class _ModSwapAllMotionsSelectButtonState extends State<ModSwapAllMotionsSelectButton> {
  final motionTypes = ['All', 'Glide Motion', 'Jump Motion', 'Landing Motion', 'Dash Motion', 'Run Motion', 'Standby Motion', 'Swim Motion'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.motions,
          value: appText.motionTypeName(selectedModSwapAllMotionType.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedModSwapAllMotionType.value = value!;
            widget.rScrollController.jumpTo(0);
          },
          itemCount: motionTypes.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: appText.motionTypeName(motionTypes[i]),
              groupValue: state.single,
              onChanged: (value) {
                state.select(motionTypes[i]);
              },
              title: ChoiceText(
                appText.motionTypeName(motionTypes[i]),
                highlight: state.search?.value,
                style: TextStyle(color: selectedModSwapAllMotionType.watch(context) == motionTypes[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}
