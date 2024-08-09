import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/home_page.dart';
import 'package:pso2_mod_manager/homepage/mod_view.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';

class Preview extends StatefulWidget {
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: <Widget>[Container()],
        title: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: Text(previewModName.isNotEmpty ? '${curLangText!.uiPreview}: $previewModName' : curLangText!.uiPreview),
        ),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: 30,
        elevation: 0,
      ),
      body: (previewImages.isNotEmpty && !hoveringOnSubmod) || (previewImages.isNotEmpty && hoveringOnSubmod)
          ? Expanded(
              child: FlutterCarousel.builder(
                options: CarouselOptions(
                    autoPlay: previewImages.length > 1,
                    autoPlayInterval: previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                        ? const Duration(seconds: 5)
                        : previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
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
                itemCount: previewImages.length,
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => previewImages[itemIndex],
              ),
            )
          : Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).canvasColor.withOpacity(0.8), borderRadius: const BorderRadius.all(Radius.circular(2))),
                    child: Text(
                      curLangText!.uiNoPreViewAvailable,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
