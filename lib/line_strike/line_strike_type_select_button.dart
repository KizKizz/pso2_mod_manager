import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_image_crop_popup.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<LineStrikeItemType> selectedLineStrikeType = Signal<LineStrikeItemType>(LineStrikeItemType.card);

class LineStrikeTypeSelectButton extends StatefulWidget {
  const LineStrikeTypeSelectButton({super.key, required this.lScrollController, required this.rScrollController});

  final ScrollController lScrollController;
  final ScrollController rScrollController;

  @override
  State<LineStrikeTypeSelectButton> createState() => _LineStrikeTypeSelectButtonState();
}

class _LineStrikeTypeSelectButtonState extends State<LineStrikeTypeSelectButton> {
  @override
  Widget build(BuildContext context) {
    final typeList = [appText.cards, appText.boards, appText.sleeves];
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.view,
          value: selectedLineStrikeType.value == LineStrikeItemType.card
              ? typeList[0]
              : selectedLineStrikeType.value == LineStrikeItemType.board
                  ? typeList[1]
                  : typeList[2],
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            value! == typeList[0]
                ? selectedLineStrikeType.value = LineStrikeItemType.card
                : value == typeList[1]
                    ? selectedLineStrikeType.value = LineStrikeItemType.board
                    : selectedLineStrikeType.value = LineStrikeItemType.sleeve;
            widget.lScrollController.jumpTo(0);
            widget.rScrollController.jumpTo(0);
          },
          itemCount: typeList.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: typeList[i],
              groupValue: state.single,
              onChanged: (value) {
                state.select(typeList[i]);
              },
              title: ChoiceText(
                appText.categoryName(typeList[i]),
                highlight: state.search?.value,
                style: TextStyle(color: selectedLineStrikeType.watch(context) == typeList[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}
