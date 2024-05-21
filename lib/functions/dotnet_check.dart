import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void dotnetVerCheck(context) {
  if (Platform.isWindows) {
    Process.run('dotnet', ['--list-runtimes']).then((value) {
      String results = value.stdout;
      List<String> resultList = results.split('\n');
      //debugPrint(resultList.length.toString());
      List<String> dotnetVerList = [];
      for (var line in resultList) {
        if (line.isNotEmpty) {
          dotnetVerList.add(line.split(' ')[1]);
        }
      }
      bool reqDotnetVerFound = false;
      for (var ver in dotnetVerList) {
        String majorVerString = ver.split('.').first;
        int majorVer = int.tryParse(majorVerString) == null ? 0 : int.parse(majorVerString);
        if (majorVer >= 6) {
          reqDotnetVerFound = true;
          break;
        }
      }

      if (!reqDotnetVerFound) {
        dotNetDialog(context, resultList);
      }
    });
  }
}

Future<void> dotNetDialog(context, List<String> dotnetVerList) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
        titlePadding: const EdgeInsets.only(top: 10),
        title: Center(child: Text(curLangText!.uiRequiredDotnetRuntimeMissing)),
        contentPadding: const EdgeInsets.all(10),
        content: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
              }
              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
            }),
          ),
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                curLangText!.uiRequiresDotnetRuntimeToWorkProperly,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 5,
              ),
              Text('${curLangText!.uiYourDotNetVersions}:'),
              Text(dotnetVerList.join('\n').trim()),
              const SizedBox(
                height: 10,
              ),
              Text(curLangText!.uiUseButtonBelowToGetDotnet, style: const TextStyle(fontWeight: FontWeight.w500),)
            ],
          )),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(curLangText!.uiClose),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(curLangText!.uiGetDotnetRuntime6),
            onPressed: () {
              launchUrl(Uri.parse('https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-6.0.21-windows-x64-installer'));
            },
          ),
        ],
      );
    },
  );
}
