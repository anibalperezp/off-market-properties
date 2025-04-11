import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

updateApp() async {
  const urlAndroid =
      'https://play.google.com/store/apps/details?id=com.xxxxxxx.xxxxxxx';
  const urlIOS =
      'https://apps.apple.com/us/app/xxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxx';

  String url = Platform.isAndroid ? urlAndroid : urlIOS;

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
