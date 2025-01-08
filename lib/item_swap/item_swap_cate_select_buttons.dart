import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

class ItemSwapCateSelectButtons extends StatefulWidget {
  const ItemSwapCateSelectButtons({super.key, required this.categoryNames, required this.scrollController});

  final List<String> categoryNames;
  final ScrollController scrollController;

  @override
  State<ItemSwapCateSelectButtons> createState() => _ItemSwapCateSelectButtonsState();
}

class _ItemSwapCateSelectButtonsState extends State<ItemSwapCateSelectButtons> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
        title: appText.view,
        value: appText.categoryName(selectedDisplayItemSwapCategory.value),
        modalFit: FlexFit.tight,
        onChanged: (value) async {
          selectedDisplayItemSwapCategory.value = value!;
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
              style: TextStyle(color: selectedDisplayItemSwapCategory.watch(context) == widget.categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
            ),
          );
        },
        promptDelegate: ChoicePrompt.delegateBottomSheet(),
        anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)
      ),
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