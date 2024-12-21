import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pso2_mod_manager/app_locale.dart';
import 'package:pso2_mod_manager/global_vars.dart';

class LanguageSelect extends StatefulWidget {
  const LanguageSelect({super.key});

  @override
  State<LanguageSelect> createState() => _LanguageSelectState();
}

class _LanguageSelectState extends State<LanguageSelect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppLocale.selectALanguage.getString(context)),
          Wrap(
            spacing: 5,
            children: [
              ElevatedButton(
                  onPressed: () {
                    localization.translate('jp');
                  },
                  child: Text('test'))
            ],
          )
        ],
      ),
    );
  }
}
