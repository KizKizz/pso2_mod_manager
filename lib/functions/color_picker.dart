import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Color pickerColor = const Color(0x001759c2);
Color currentColor = const Color(0xff443a49);
Color? selectedColor;

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
    return MaterialColor(Color.fromRGBO(r, g, b, 1).value, color);
  }
}

Future<void> getColor(context) async {
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            elevation: 10,
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(500))),
            content: SizedBox(
              width: 250,
              //eight: 450,
              child: SingleChildScrollView(
                child: Column(
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
                    const Text(
                      'Pick a color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Reset'),
                            onPressed: () {
                              setState(() => pickerColor = currentColor);
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Got it'),
                            onPressed: () {
                              setState(() {
                                selectedColor = pickerColor;
                                //print(pickerColor);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      });
}
