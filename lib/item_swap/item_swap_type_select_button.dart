import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedItemSwapTypeCategory = Signal<String>(appText.both);

class ItemSwapTypeSelectButtons extends StatefulWidget {
  const ItemSwapTypeSelectButtons({super.key, required this.lScrollController, required this.rScrollController});

  final ScrollController lScrollController;
  final ScrollController rScrollController;

  @override
  State<ItemSwapTypeSelectButtons> createState() => _ItemSwapTypeSelectButtonsState();
}

class _ItemSwapTypeSelectButtonsState extends State<ItemSwapTypeSelectButtons> {
  final itemTypes = [appText.both, 'PSO2', 'NGS'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.types,
          value: appText.categoryName(selectedItemSwapTypeCategory.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedItemSwapTypeCategory.value = value!;
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
                style: TextStyle(color: selectedItemSwapTypeCategory.watch(context) == itemTypes[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
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
