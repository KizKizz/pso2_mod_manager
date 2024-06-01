import 'dart:io';

Future<bool> connectedToInternet() async {
  try {
    final result = await InternetAddress.lookup('github.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}