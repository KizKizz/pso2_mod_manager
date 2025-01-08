import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

class ModSetSelectButtons extends StatefulWidget {
  const ModSetSelectButtons({super.key, required this.setNames, required this.scrollController});

  final List<String> setNames;
  final ScrollController scrollController;

  @override
  State<ModSetSelectButtons> createState() => _ModSetSelectButtonsState();
}

class _ModSetSelectButtonsState extends State<ModSetSelectButtons> {
  @override
  Widget build(BuildContext context) {
    if (!widget.setNames.contains('All')) widget.setNames.insert(0, 'All');
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
        title: appText.view,
        value: selectedDisplayModSet.value,
        modalFit: FlexFit.tight,
        onChanged: (value) async {
          selectedDisplayModSet.value = value!;
          widget.scrollController.jumpTo(0);
        },
        itemCount: widget.setNames.length,
        itemBuilder: (state, i) {
          return RadioListTile(
            value: widget.setNames[i],
            groupValue: state.single,
            onChanged: (value) {
              state.select(widget.setNames[i]);
            },
            title: ChoiceText(
              appText.categoryName(widget.setNames[i]),
              highlight: state.search?.value,
              style: TextStyle(color: selectedDisplayModSet.watch(context) == widget.setNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
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