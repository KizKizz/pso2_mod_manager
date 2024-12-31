import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pso2_mod_manager/app_colorscheme.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

class CustomMaterialColor {
  final int r;
  final int g;
  final int b;

  CustomMaterialColor(this.r, this.g, this.b);

  MaterialColor get materialColor {
    Map<int, Color> color = {
      50: Color.fromRGBO(r, g, b, .1),
      100: Color.fromRGBO(r, g, b, .2),
      200: Color.fromRGBO(r, g, b, .3),
      300: Color.fromRGBO(r, g, b, .4),
      400: Color.fromRGBO(r, g, b, .5),
      500: Color.fromRGBO(r, g, b, .6),
      600: Color.fromRGBO(r, g, b, .7),
      700: Color.fromRGBO(r, g, b, .8),
      800: Color.fromRGBO(r, g, b, .9),
      900: Color.fromRGBO(r, g, b, 1),
    };
    // ignore: deprecated_member_use
    return MaterialColor(Color.fromRGBO(r, g, b, 1).value, color);
  }
}

Future<Color?> colorPicker(context, Color startingColor) async {
  Color pickerColor = startingColor;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            elevation: 10,
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.vertical(top: Radius.circular(500))),
            content: SizedBox(
              width: 250,
              //eight: 450,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      HueRingPicker(
                        portraitOnly: true,
                        pickerColor: pickerColor,
                        enableAlpha: true,
                        displayThumbColor: true,
                        onColorChanged: (Color value) {
                          pickerColor = value;
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: Text(appText.resetToDefaultColor),
                          onPressed: () {
                            if (appThemeMode == AppThemeMode.light) {
                              pickerColor = lightColorScheme.primary;
                            } else {
                              pickerColor = darkColorScheme.primary;
                            }
                            setState(
                              () {},
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: Text(appText.resetToStartingColor),
                          onPressed: () {
                            setState(() => pickerColor = startingColor);
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: Text(appText.saveSelectedColorAndReturn),
                          onPressed: () {
                            Navigator.of(context).pop(pickerColor);
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          child: Text(appText.returnWithoutSaving),
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      });
}
