import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> selectedAqmInjectCategory = Signal<String>(aqmInjectCategoryDirs[0]);

class AqmInjectCateSelectButton extends StatefulWidget {
  const AqmInjectCateSelectButton(
      {super.key, required this.categoryNames, required this.lSelectedItemData, required this.lScrollController});

  final List<String> categoryNames;
  final ScrollController lScrollController;
  final Signal<ItemData?> lSelectedItemData;

  @override
  State<AqmInjectCateSelectButton> createState() => _AqmInjectCateSelectButtonState();
}

class _AqmInjectCateSelectButtonState extends State<AqmInjectCateSelectButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: PromptedChoice<String>.single(
          title: appText.view,
          value: appText.categoryName(selectedAqmInjectCategory.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            selectedAqmInjectCategory.value = value!;
            widget.lScrollController.jumpTo(0);
          },
          itemCount: widget.categoryNames.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: widget.categoryNames[i],
              groupValue: state.single,
              onChanged: (value) {
                state.select(widget.categoryNames[i]);
                widget.lSelectedItemData.value = null;
              },
              title: ChoiceText(
                appText.categoryName(widget.categoryNames[i]),
                highlight: state.search?.value,
                style:
                    TextStyle(color: selectedAqmInjectCategory.watch(context) == widget.categoryNames[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}
