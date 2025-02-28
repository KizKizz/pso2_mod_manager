import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:window_manager/window_manager.dart';

class FutureBuilderLoading extends StatelessWidget {
  const FutureBuilderLoading({super.key, required this.loadingText});

  final String loadingText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardOverlay(
        paddingValue: 15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                loadingText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FutureBuilderError extends StatelessWidget {
  const FutureBuilderError({super.key, required this.loadingText, required this.snapshotError, required this.isPopup});

  final String loadingText;
  final String snapshotError;
  final bool isPopup;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardOverlay(
        paddingValue: 15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.halfTriangleDot(
              color: Colors.red,
              size: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(appText.error, style: Theme.of(context).textTheme.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text('($loadingText)', style: Theme.of(context).textTheme.bodyLarge),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(snapshotError, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton(onPressed: () => isPopup ? Navigator.of(context).pop() : windowManager.close(), child: Text(isPopup ? appText.returns : appText.exit)),
            )
          ],
        ),
      ),
    );
  }
}
