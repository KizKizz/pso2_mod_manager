import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/material_app_service.dart';

dynamic _context = MaterialAppService.navigatorKey.currentContext!;

void errorNotification(message) {
  ElegantNotification.error(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRightE',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.error,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      message,
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

void deletedNotification(name) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.success,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dText(appText.successfullyDeletedItem, name),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

void restoreSuccessNotification(name) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.success,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dText(appText.successfullyRestoredFile, name),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

void restoreFailedNotification(name) {
  ElegantNotification.error(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRightE',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.failed,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dText(appText.failedToRestoredFile, name),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

void applySuccessNotification(name) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.success,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dText(appText.successfullyAppliedFile, name),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

void applyFailedNotification(name) {
  ElegantNotification.error(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRightE',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.failed,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dText(appText.failedToApplyFile, name),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}

// Mod sets
void addToSetSuccessNotification(String names, String modSetName) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.success,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dTexts(appText.modHasBeenAddedToSet, [names, modSetName]),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}
void removeFromSetSuccessNotification(String names, String modSetName) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(_context).scaffoldBackgroundColor.withAlpha(50),
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(_context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      appText.success,
      style: Theme.of(_context).textTheme.titleMedium,
    ),
    description: Text(
      appText.dTexts(appText.modHasBeenRemovedFromSet, [names, modSetName]),
      style: Theme.of(_context).textTheme.bodyMedium,
    ),
    shadow: BoxShadow(color: Theme.of(_context).shadowColor),
    onDismiss: () {},
  ).show(_context);
}
