import 'package:flutter/material.dart';
import 'package:zipcular/commons/notification.global.dart';
import 'package:zipcular/containers/homepage.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'package:zipcular/repository/services/prod/search.service.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class Home extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => Home());
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserRepository userRepository = UserRepository();
  double latitude = 31.8381101;
  double longitude = -97.6119098;
  double zoom = 6;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserFromDatabase();
      final tags =
          Provider.of<UserProvider>(context, listen: false).user.sSystemTags;
      Provider.of<FilterProvider>(context, listen: false)
          .updateSystemTags(tags);
      await Provider.of<FilterProvider>(context, listen: false)
          .fetchFiltersFromDatabase();
      String counter = await userRepository.readKey('notifications_total');
      await notificationsGlobalCount(counter);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider(
        create: (_) => Search(),
        child: HomePage(
            latitude: this.latitude,
            longitude: this.longitude,
            zoom: this.zoom),
      ),
    );
  }
}
