import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class ModSetSortingButton extends StatefulWidget {
  const ModSetSortingButton({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ModSetSortingButton> createState() => _ModSetSortingButtonState();
}

class _ModSetSortingButtonState extends State<ModSetSortingButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
        title: appText.sort,
        value: appText.sortingTypeName(selectedDisplaySortModSet.value),
        modalFit: FlexFit.tight,
        onChanged: (value) async {
          final prefs = await SharedPreferences.getInstance();
          selectedDisplaySortModSet.value = value!;
          prefs.setString('selectedDisplaySortModSet', selectedDisplaySortModSet.value);
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
              style: TextStyle(color: selectedDisplaySortModSet.watch(context) == modSortingSelections[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
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
//               titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.labelLarge!.color),
//               minTileHeight: 35,
//               minVerticalPadding: 0,
//               leadingAndTrailingTextStyle: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.labelLarge!.color)),
//           child: ChoiceAnchor.create(
//             valueTruncate: 2,
//             inline: true,
//           )(state, openModal),
//         );
//   }
// }