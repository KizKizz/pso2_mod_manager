import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';

void errorNotification(context, message) {
  ElegantNotification.error(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(context).scaffoldBackgroundColor,
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(appText.error, style: Theme.of(context).textTheme.titleMedium,),
    description: Text(message, style: Theme.of(context).textTheme.bodyMedium,),
    shadow: BoxShadow(color: Theme.of(context).shadowColor),
    onDismiss: () {},
  ).show(context);
}

void deletedNotification(context, name) {
  ElegantNotification.success(
    width: 360,
    stackedOptions: StackedOptions(
      key: 'bottomRight',
      type: StackedType.below,
      itemOffset: const Offset(0, 5),
    ),
    background: Theme.of(context).scaffoldBackgroundColor,
    notificationMargin: 1,
    border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline),
    position: Alignment.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(appText.success, style: Theme.of(context).textTheme.titleMedium,),
    description: Text(appText.dText(appText.successfullyDeletedItem, name), style: Theme.of(context).textTheme.bodyMedium,),
    shadow: BoxShadow(color: Theme.of(context).shadowColor),
    onDismiss: () {},
  ).show(context);
}
