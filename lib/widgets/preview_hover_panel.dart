import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/state_provider.dart';

class PreviewHoverPanel extends StatelessWidget {
  const PreviewHoverPanel({super.key, required this.previewWidgets});

  final List<Widget> previewWidgets;

  @override
  Widget build(BuildContext context) {
    if (previewWidgets.isNotEmpty) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
        child: Container(
          decoration: BoxDecoration(
              color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
              border: Border.all(color: Theme.of(context).primaryColorLight),
              borderRadius: const BorderRadius.all(Radius.circular(2))),
          child: FlutterCarousel.builder(
                  options: CarouselOptions(
                      autoPlay: previewWidgets.length > 1,
                      autoPlayInterval: previewWidgets.length > 1 && previewWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == previewWidgets.length
                          ? const Duration(seconds: 5)
                          : previewWidgets.length > 1 && previewWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == previewWidgets.length
                              ? const Duration(seconds: 1)
                              : const Duration(seconds: 2),
                      disableCenter: true,
                      viewportFraction: 1.0,
                      height: double.infinity,
                      floatingIndicator: false,
                      enableInfiniteScroll: true,
                      indicatorMargin: 4,
                      slideIndicator: CircularWaveSlideIndicator(
                          slideIndicatorOptions: SlideIndicatorOptions(
                              itemSpacing: 10,
                              indicatorRadius: 4,
                              currentIndicatorColor: Theme.of(context).colorScheme.primary,
                              indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3)))),
                  itemCount: previewWidgets.length,
                  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => previewWidgets[itemIndex],
                ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
