import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';

class VitalGaugeBackgroundTile extends StatefulWidget {
  const VitalGaugeBackgroundTile({super.key, required this.background});

  final VitalGaugeBackground background;

  @override
  State<VitalGaugeBackgroundTile> createState() => _VitalGaugeBackgroundTileState();
}

class _VitalGaugeBackgroundTileState extends State<VitalGaugeBackgroundTile> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return Center(
          child: widget.background.isReplaced
              ? AspectRatio(
                  aspectRatio: 29 / 6,
                  child: Container(
                    decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.background.pngPath,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                            ),
                            ClipPath(
                              clipper: CustomClipLayerPath(),
                              child: Container(
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                            ClipPath(
                              clipper: CustomClipPath(),
                              child: Image.file(
                                File(widget.background.replacedImagePath),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 1, bottom: 1),
                          child: ModManTooltip(
                            message: curLangText!.uiHoldToRestoreThisBackgroundToItsOriginal,
                            child: InkWell(
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                ),
                                child: const Icon(
                                  Icons.restore,
                                  color: Colors.red,
                                ),
                              ),
                              onLongPress: () async {
                                String downloadedFilePath =
                                    await downloadIconIceFromOfficial(widget.background.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                try {
                                  File(downloadedFilePath).copySync(widget.background.icePath);
                                  widget.background.replacedMd5 = '';
                                  widget.background.replacedImagePath = '';
                                  widget.background.replacedImageName = '';
                                  widget.background.isReplaced = false;
                                  saveVitalGaugesInfoToJson(vgData);
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${widget.background.iceName}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    AspectRatio(
                      aspectRatio: 29 / 6,
                      child: Container(
                        decoration:
                            ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
                        child: Image.network(
                          widget.background.pngPath,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    if (_loading[i])
                      Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
        );
      },
      onAcceptWithDetails: (data) {
        _loading[i] = true;
        setState(
          () {},
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(
            () {
              String imgPath = data.data.toString();
              customVgBackgroundApply(context, imgPath, widget.background).then((value) {
                if (value) {
                  widget.background.replacedImagePath = imgPath;
                  widget.background.replacedImageName = p.basename(imgPath);
                  widget.background.isReplaced = true;
                  saveVitalGaugesInfoToJson(vgData);
                  // Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                  //   element.deleteSync(recursive: true);
                  // });
                  _loading[i] = false;
                  setState(
                    () {},
                  );
                } else {
                  _loading[i] = false;
                  setState(
                    () {},
                  );
                }
              });
            },
          );
        });
      },
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  //var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 200);
    path.lineTo(200, 200);
    path.lineTo(460, 0);
    path.lineTo(230, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomClipLayerPath extends CustomClipper<Path> {
  //var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 200);
    path.lineTo(200, 200);
    path.lineTo(463, 0);
    path.lineTo(235, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}