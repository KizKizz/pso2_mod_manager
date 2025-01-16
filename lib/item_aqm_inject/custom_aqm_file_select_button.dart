import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

class CustomAqmSelectButtons extends StatefulWidget {
  const CustomAqmSelectButtons({super.key, required this.aqmFilePaths});

  final List<String> aqmFilePaths;

  @override
  State<CustomAqmSelectButtons> createState() => _CustomAqmSelectButtonsState();
}

class _CustomAqmSelectButtonsState extends State<CustomAqmSelectButtons> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: PromptedChoice<String>.single(
          title: appText.currentAqmFile,
          value: p.basename(selectedCustomAQMFilePath.value),
          modalFit: FlexFit.tight,
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            selectedCustomAQMFilePath.value = value!;
            prefs.setString('selectedCustomAQMFilePath', selectedCustomAQMFilePath.value);
          },
          itemCount: widget.aqmFilePaths.length,
          itemBuilder: (state, i) {
            return RadioListTile(
              value: p.basename(widget.aqmFilePaths[i]),
              groupValue: state.single,
              onChanged: (value) {
                state.select(widget.aqmFilePaths[i]);
              },
              title: ChoiceText(
                p.basename(widget.aqmFilePaths[i]),
                highlight: state.search?.value,
                style: TextStyle(color: selectedCustomAQMFilePath.watch(context) == widget.aqmFilePaths[i] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color),
              ),
            );
          },
          promptDelegate: ChoicePrompt.delegateBottomSheet(),
          anchorBuilder: (state, openModal) => ChoiceAnchorLayout(state: state, openModal: openModal)),
    );
  }
}

class ChoiceAnchorLayout extends StatelessWidget {
  const ChoiceAnchorLayout({super.key, required this.state, required this.openModal});

  final ChoiceController<String> state;
  final Function() openModal;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(50))),
          tileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 2),
          titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          minTileHeight: 28,
          minVerticalPadding: 0,
          leadingAndTrailingTextStyle: const TextStyle(fontSize: 15)),
      child: ChoiceAnchor.create(
        valueTruncate: 2,
        inline: true,
      )(state, openModal),
    );
  }
}
