import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedItemSwapMotionType = Signal<String>(appText.all);

class ItemSwapMotionTypeSelectButtons extends StatefulWidget {
  const ItemSwapMotionTypeSelectButtons({super.key, required this.lScrollController, required this.rScrollController});

  final ScrollController lScrollController;
  final ScrollController rScrollController;

  @override
  State<ItemSwapMotionTypeSelectButtons> createState() => _ItemSwapMotionTypeSelectButtonsState();
}

class _ItemSwapMotionTypeSelectButtonsState extends State<ItemSwapMotionTypeSelectButtons> {
  final motionTypes = [appText.all, 'Glide Motion', 'Jump Motion', 'Landing Motion', 'Dash Motion', 'Run Motion', 'Standby Motion', 'Swim Motion'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.motions,
          value: appText.motionTypeName(selectedItemSwapMotionType.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedItemSwapMotionType.value = value!;
            widget.lScrollController.jumpTo(0);
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
                motionTypes[i],
                highlight: state.search?.value,
                style: TextStyle(color: selectedItemSwapMotionType.watch(context) == motionTypes[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}

// class ChoiceAnchorLayout extends StatelessWidget {
//   const ChoiceAnchorLayout({super.key, required this.state, required this.openModal});

//   final ChoiceController<String> state;
//   final Function() openModal;

//   @override
//   Widget build(BuildContext context) {
//     return ListTileTheme(
//           data: ListTileThemeData(
//               shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(50))),
//               tileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
//               contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 2),
//               titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               minTileHeight: 35,
//               minVerticalPadding: 0,
//               leadingAndTrailingTextStyle: const TextStyle(fontSize: 15)),
//           child: ChoiceAnchor.create(
//             valueTruncate: 2,
//             inline: true,
//           )(state, openModal),
//         );
//   }
// }
