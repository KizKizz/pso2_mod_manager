import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_popups.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_functions.dart';

class VitalGaugeBackgroundTile extends StatefulWidget {
  const VitalGaugeBackgroundTile({super.key, required this.background, required this.vitalGaugeBackgroundList});

  final List<VitalGaugeBackground> vitalGaugeBackgroundList;
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
                          padding: const EdgeInsets.all(2.5),
                          child: OutlinedButton(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                              onPressed: () async {
                                bool result = await vitalGaugeRestorePopup(context, widget.background);
                                if (result) {
                                  widget.background.replacedMd5 = '';
                                  widget.background.replacedImagePath = '';
                                  widget.background.replacedImageName = '';
                                  widget.background.isReplaced = false;
                                  saveMasterVitalGaugeToJson(widget.vitalGaugeBackgroundList);
                                  setState(() {});
                                }
                              },
                              child: Text(appText.restore)),
                        )
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
                  ],
                ),
        );
      },
      onAcceptWithDetails: (data) async {
        final result = await vitalGaugeApplyPopup(context, data.data.toString(), widget.background);
        if (result) {
          widget.background.replacedImagePath = data.data.toString();
          widget.background.replacedImageName = p.basename(data.data.toString());
          widget.background.isReplaced = true;
          setState(() {});
          saveMasterVitalGaugeToJson(widget.vitalGaugeBackgroundList);
        }
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
