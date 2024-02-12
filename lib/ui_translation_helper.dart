String uiInTextArgs(String uiText, List<String> inTextArgs, List<dynamic> args) {
  String tempText = uiText;
  if (inTextArgs.length == args.length) {
    for (int i = 0; i < inTextArgs.length; i++) {
      tempText = tempText.replaceAll(inTextArgs[i], args[i]);
    }
  }

  return tempText;
}

String uiInTextArg(String uiText, dynamic arg) {
  return uiText.replaceAll('<x>', arg);
}
