import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ModSettingsLayout extends StatefulWidget {
  const ModSettingsLayout({super.key});

  @override
  State<ModSettingsLayout> createState() => _ModSettingsLayoutState();
}

class _ModSettingsLayoutState extends State<ModSettingsLayout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appText.modSettings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const HoriDivider(),
        SingleChildScrollView(
          physics: SuperRangeMaintainingScrollPhysics(),
          child: Column(
            spacing: 5,
            children: [],
          ),
        )
      ],
    );
  }
}
