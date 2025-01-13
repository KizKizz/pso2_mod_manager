import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/settings/app_settings.dart';
import 'package:pso2_mod_manager/settings/mod_settings.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return const CardOverlay(
      paddingValue: 10,
        child: Row(
          spacing: 5,
      children: [
        Expanded(flex: 1, child: AppSettingsLayout()),
        Expanded(flex: 1, child: ModSettingsLayout()),
        Expanded(flex: 1, child: OtherSettingsLayout()),
      ],
    ));
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Icon(icon),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge,
        )
      ],
    );
  }
}
