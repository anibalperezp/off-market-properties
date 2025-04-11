import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../../../repository/store/auth_view/intro/intro_bloc.dart';
import '../../../../repository/store/auth_view/intro/intro_event.dart';
import '../../../../repository/store/auth_view/intro/intro_state.dart';

class SliderPartialIntro extends StatelessWidget {
  SliderPartialIntro({Key? key}) : super(key: key);

  final UserRepository userRepository = new UserRepository();
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName, [double width = 400]) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Image.asset('assets/images/$assetName', width: width));
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 25.0, fontWeight: FontWeight.w700, color: headerColor),
        bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white),
        bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        pageColor: backgroundColor,
        imageFlex: 2,
        imagePadding: EdgeInsets.only(top: 30),
        contentMargin: EdgeInsets.only(top: 30));

    return BlocListener<IntroBloc, IntroState>(
        listener: (context, state) {},
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: IntroductionScreen(
              key: introKey,
              globalBackgroundColor: backgroundColor,
              // globalHeader: Align(
              //   alignment: Alignment.topRight,
              //   child: SafeArea(
              //     child: Padding(
              //       padding: const EdgeInsets.only(top: 16, right: 16),
              //       child: _buildImage('flutter.png', 100),
              //     ),
              //   ),
              // ),
              pages: [
                PageViewModel(
                  title: "Marketplace",
                  body:
                      "Buy and Sell with less or no intermediaries. An alternative where you have full control and freedom.",
                  image: _buildImage('img1.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: "Sell Fast",
                  body:
                      "You deserve to get the most for your property. Expose it! It's private, simple and free.",
                  image: _buildImage('img2.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: "Buy without Banks",
                  body:
                      "Can't get approved by a bank? You can find seller financing deals using our filters.",
                  image: _buildImage('img3.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: "Connect",
                  body:
                      'Find Attorneys, Title Companies, Money Lenders, Contractors and more...',
                  image: _buildImage('img4.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: "Tools",
                  body:
                      'It is a long established fact that a reader will be distracted by the readable content.',
                  image: _buildImage('img5.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: "Grow your Business",
                  body:
                      "No more buyer email lists. Tell your buyers to follow you, we'll notify them when you upload a property.",
                  image: _buildImage('img6.png'),
                  decoration: pageDecoration,
                )
              ],
              onDone: () {
                userRepository.writeToken('intro', 'TRUE');
                context.read<IntroBloc>().add(IntroSubmitted());
              },
              showSkipButton: true,
              skipOrBackFlex: 0,
              nextFlex: 0,
              skip: const Text('Skip',
                  style: TextStyle(fontSize: 18, color: headerColor)),
              next: const Icon(Icons.arrow_forward, color: headerColor),
              done: const Text('Done',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: headerColor)),
              curve: Curves.fastLinearToSlowEaseIn,
              controlsMargin: const EdgeInsets.all(16),
              controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
              // color: headerColor,
              // skipColor: headerColor,
              // doneColor: headerColor,
              // nextColor: headerColor,

              dotsDecorator: const DotsDecorator(
                activeColor: headerColor,
                size: Size(10.0, 10.0),
                color: Colors.grey,
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              dotsContainerDecorator: const ShapeDecoration(
                color: Color.fromRGBO(38, 42, 52, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            )));
  }
}
