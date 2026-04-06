import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/app_localization/app_locale.dart';

Future<bool> githubAccessCheck() async {
  try {
    final response = await http.get(Uri.parse(localeSettingsGitHubLink));
    if (response.statusCode == 200) {
      return false;
    } else {
      return true;
    }
  } catch (e) {
    return true;
  }
}
