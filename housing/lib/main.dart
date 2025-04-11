import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/firebase_options.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/provider/favorites.provider.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';
import 'package:zipcular/repository/provider/network.provider.dart';
import 'package:zipcular/repository/provider/notifications.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'main/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NotificationsProvider()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => NetworkProvider()),
          ChangeNotifierProvider(create: (_) => FilterProvider()),
        ],
        child: App(),
      ),
    );
  });
}
