import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool firstBootUp = true;
ItemNameLanguage itemNameLanguage = ItemNameLanguage.en;
String appVersionUpdateSkip = '';

int modManCurActiveProfile = 1;
String pso2binDirPath = '';
String mainDataDirPath = '';
int uiBackgroundColorAlpha = 150;

Future<void> prefsLoad() async {
  final prefs = await SharedPreferences.getInstance();

  // First time boot
  firstBootUp = prefs.getBool('firstBootUp') ?? true;

  // Item Name Language
  itemNameLanguage = ItemNameLanguage.values.firstWhere((e) => e.value == prefs.getString('itemNameLanguage'), orElse: () => ItemNameLanguage.en);

  // App Version Update Skip
  appVersionUpdateSkip = prefs.getString('appVersionUpdateSkip') ?? '';

  // Active Profile
  modManCurActiveProfile = prefs.getInt('modManCurActiveProfile') ?? 1;

  // pso2bin dir path
  pso2binDirPath = modManCurActiveProfile == 1 ? prefs.getString('pso2binDirPath') ?? '' : prefs.getString('pso2binDirPath_profile2') ?? '';

  // Main dir path
  mainDataDirPath = prefs.getString('mainDataDirPath') ?? '';
  
  // Main dir path
  uiBackgroundColorAlpha = prefs.getInt('uiBackgroundColorAlpha') ?? 150;
}
