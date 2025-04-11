import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/store/splash/loading_animation.widget.dart';

class SplashPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SplashPage());
  }

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimation(),
              SizedBox(height: 12),
              Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: new AlwaysStoppedAnimation<Color>(headerColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
