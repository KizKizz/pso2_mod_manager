import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';

Future<void> getColor(context) async {
  return await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => AlertDialog(
                      titlePadding: const EdgeInsets.all(0),
                      contentPadding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                            ? const BorderRadius.vertical(
                                top: Radius.circular(500),
                                bottom: Radius.circular(100),
                              )
                            : const BorderRadius.horizontal(right: Radius.circular(500)),
                      ),
                      content: SingleChildScrollView(
                        child: HueRingPicker(
                          pickerColor: pickerColor,
                          enableAlpha: true,
                          displayThumbColor: true, 
                          onColorChanged: (Color value) {  },
                        ),
                      ),
                    
      // actions: <Widget>[
      //   ElevatedButton(
      //     child: const Text('Got it'),
      //     onPressed: () {
      //       //setState(() => currentColor = pickerColor);
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    ),
  );
}
