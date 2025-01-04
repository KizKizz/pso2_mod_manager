import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/app_localization/app_locale.dart';

Future<bool> githubAccessCheck() async {
  final response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/Locale/LocaleSetting.json'));

  if (response.statusCode == 200) {
    return false;
  } else {
    return true;
  }
}
