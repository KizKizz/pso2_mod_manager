import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

double _downloadPercent = 0;
String _downloadErrorMsg = '';

Future<void> patchNotesDialog(context) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
        titlePadding: const EdgeInsets.only(top: 10),
        title: Center(child: Text(curLangText!.uiPatchNotes)),
        contentPadding: const EdgeInsets.all(10),
        content: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (int index = 0; index < patchNoteSplit.length; index++) Text('- ${patchNoteSplit[index]}')],
        )),
        actions: <Widget>[
          ElevatedButton(
            child: Text(curLangText!.uiClose),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(curLangText!.uiGoToDownloadPage),
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
            },
          ),
          ElevatedButton(
            child: Text(curLangText!.uiDownloadUpdate),
            onPressed: () {
              Navigator.of(context).pop();
              appDownloadDialog(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> appDownloadDialog(context) async {
  Dio dio = Dio();
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (dialogContext, setState) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_downloadPercent <= 0 && _downloadErrorMsg.isEmpty) {
            try {
              await dio.download("https://github.com/KizKizz/pso2_mod_manager/raw/main/updater/updater.exe", Uri.file('${Directory.current.path}/appUpdate/updater.exe').toFilePath());
            } catch (e) {
              debugPrint(e.toString());
              _downloadErrorMsg = e.toString();
            }
            try {
              await dio.download('https://github.com/KizKizz/pso2_mod_manager/releases/download/v$newVersion/PSO2NGSModManager_v$newVersion.zip',
                  Uri.file('${Directory.current.path}/appUpdate/PSO2NGSModManager_v$newVersion.zip').toFilePath(), options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
                  onReceiveProgress: (received, total) async {
                if (total != -1) {
                  _downloadPercent = received / total * 100;
                  if (_downloadPercent >= 100) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    await extractFileToDisk(Uri.file('${Directory.current.path}/appUpdate/PSO2NGSModManager_v$newVersion.zip').toFilePath(),
                        Uri.file('${Directory.current.path}/appUpdate/PSO2NGSModManager_v$newVersion').toFilePath(),
                        asyncWrite: false);
                    //create launcher bat
                    File patchLauncher = await patchFileLauncherGenerate();
                    if (patchLauncher.existsSync()) {
                      Process.run(patchLauncher.path, []);
                    } else {
                      _downloadErrorMsg = curLangText!.uiDownloadingUpdateError;
                    }

                    // if (File(Uri.file('${Directory.current.path}/appUpdate/updater.exe').toFilePath()).existsSync()) {
                    //   Process.run(Uri.file('${Directory.current.path}/appUpdate/updater.exe').toFilePath(), ['PSO2NGSModManager', newVersion, '"${Directory.current.path}"'], runInShell: true);
                    // } else {
                    //   _downloadErrorMsg = curLangText!.uiDownloadingUpdateError;
                    // }
                    //Process.run(Uri.file('${Directory.current.path}/appUpdate/PSO2NGSMMUpdater.exe').toFilePath(), []);

                    // await patchFileGenerate();
                    // File patchLauncher = await patchFileLauncherGenerate();
                    // Process.run(patchLauncher.path, []);
                    //windowManager.destroy();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                  setState(
                    () {},
                  );
                }
              });
            } catch (e) {
              setState(
                () {
                  _downloadErrorMsg = e.toString();
                },
              );
            }
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
          backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
          titlePadding: const EdgeInsets.only(top: 10),
          title: Center(child: _downloadErrorMsg.isEmpty ? Text(curLangText!.uiDownloadingUpdate) : Text(curLangText!.uiDownloadingUpdateError)),
          contentPadding: const EdgeInsets.all(10),
          content: _downloadErrorMsg.isNotEmpty
              ? Text(_downloadErrorMsg)
              : Stack(
                  alignment: Alignment.center,
                  children: [const SizedBox(width: 60, height: 60, child: CircularProgressIndicator()), Text('${_downloadPercent.toStringAsFixed(0)} %')],
                ),
          actions: <Widget>[
            Visibility(
              visible: _downloadErrorMsg.isNotEmpty,
              child: ElevatedButton(
                child: Text(curLangText!.uiGoToDownloadPage),
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                  dio.close();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Visibility(
              visible: _downloadErrorMsg.isNotEmpty,
              child: ElevatedButton(
                child: Text(curLangText!.uiClose),
                onPressed: () {
                  dio.close();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      });
    },
  );
}

Future<File> patchFileLauncherGenerate() async {
  File patchFile = File(Uri.file('${Directory.current.path}/appUpdate/patchLauncher.bat').toFilePath());
  if (!patchFile.existsSync()) {
    patchFile.createSync(recursive: true);
  }
  String commands = 'start /B /D "${Uri.file('${Directory.current.path}/appUpdate/').toFilePath()}" updater.exe PSO2NGSModManager $newVersion "${Directory.current.path}"';
  await patchFile.writeAsString(commands);

  return patchFile;
}

Future<File> patchFileGenerate() async {
  File patchFile = File(Uri.file('${Directory.current.path}/appUpdate/filesPatcher.bat').toFilePath());
  if (!patchFile.existsSync()) {
    patchFile.createSync(recursive: true);
  }
  String commands =
      'xcopy "${Uri.file('${Directory.current.path}/appUpdate/PSO2NGSModManager_v$newVersion/PSO2NGSModManager').toFilePath().toString()}" "${Uri.file(Directory.current.path).toFilePath().toString()}" /Y /E /H /C /I\nstart "" /D "${Uri.file('${Directory.current.path}/').toFilePath().toString()}" PSO2NGSModManager.exe';
  await patchFile.writeAsString(commands);

  return patchFile;
}

void updatedVersionCheck(context) {
  List<String> appVersionValues = appVersion.split('.');
  int newMajor = int.parse(appVersionValues[0]);
  int newMinor = int.parse(appVersionValues[1]);
  int newPatch = int.parse(appVersionValues[2]);
  List<String> savedVersionValues = savedAppVersion.split('.');
  int savedMajor = int.parse(savedVersionValues[0]);
  int savedMinor = int.parse(savedVersionValues[1]);
  int savedPatch = int.parse(savedVersionValues[2]);
  if (newPatch > savedPatch && newMinor >= savedMinor && newMajor >= savedMajor) {
    appUpdateSuccessDialog(context);
  } else if (newPatch <= savedPatch && newMinor > savedMinor && newMajor >= savedMajor) {
    appUpdateSuccessDialog(context);
  } else if (newPatch <= savedPatch && newMinor <= savedMinor && newMajor > savedMajor) {
    appUpdateSuccessDialog(context);
  }
}

Future<void> appUpdateSuccessDialog(context) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
        titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        title: Center(child: Text(curLangText!.uiMMUpdate)),
        contentPadding: const EdgeInsets.all(10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${curLangText!.uiMMUpdateSuccess}!!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text('${curLangText!.uiVersion}: $appVersion')
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(curLangText!.uiGitHubPage),
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager#readme'));
            },
          ),
          ElevatedButton(
            child: Text(curLangText!.uiClose),
            onPressed: () async {
              //Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
              final prefs = await SharedPreferences.getInstance();
              savedAppVersion = appVersion;
              prefs.setString('savedAppVersion', savedAppVersion);
              clearAppUpdateFolder();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
