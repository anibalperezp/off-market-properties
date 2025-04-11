import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/contact-us/contact-us.component.dart';
import 'package:zipcular/containers/components/referal/referal.component.dart';
import 'package:zipcular/containers/components/settings/account_profile.settings.dart';
import 'package:zipcular/containers/components/user-network/user-network.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/creation_wizard_house.component.dart';
import 'package:zipcular/containers/main_screen/more/review_screen/review_screen.dart';
import 'package:zipcular/containers/widgets/common/animated_button.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:zipcular/repository/store/auth_view/more/more_bloc.dart';
import 'package:zipcular/repository/store/auth_view/more/more_event.dart';
import 'package:zipcular/repository/store/auth_view/more/more_state.dart';

class MorePartial extends StatefulWidget {
  final String? userSub;
  MorePartial({Key? key, this.userSub}) : super(key: key);

  @override
  State<MorePartial> createState() => _MorePartialState();
}

class _MorePartialState extends State<MorePartial>
    with TickerProviderStateMixin {
  bool showLoading = false;
  AnimationController? animationController;
  BuildContext? dialogContext;

  UserRepository _userRepository = new UserRepository();
  Listing newListing = new Listing();
  bool loadingFollowing = false;
  bool loadingFollowers = false;
  bool isNavigatingProfile = false;
  bool isNavigatingReferal = false;

  @override
  void initState() {
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController!.repeat();
    initialData();
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MoreBloc, MoreState>(
      listener: (context, state) {},
      child: Scaffold(
        body: showLoading ? buildLoadingPage() : buildSettingsList(),
      ),
    );
  }

  Widget buildSettingsList() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 50),
          child: Stack(
            children: <Widget>[
              SettingsList(
                lightTheme: SettingsThemeData(
                    dividerColor: Colors.white,
                    settingsListBackground: Colors.white,
                    settingsSectionBackground: Colors.white),
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                shrinkWrap: true,
                sections: [
                  SettingsSection(
                    margin: EdgeInsetsDirectional.all(0),
                    tiles: [
                      SettingsTile(
                        title: Text(
                          '',
                          style:
                              TextStyle(fontSize: 26, color: Colors.grey[800]),
                        ),
                        leading: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'More',
                              style: TextStyle(
                                  fontSize: 36,
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.40,
                            ),
                            userProvider.user.bUpdateApp == true
                                ? AnimatedButton()
                                : Container(),
                          ],
                        ),
                      ),
                      SettingsTile(
                        trailing: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: isNavigatingProfile == false
                              ? Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: Colors.grey[600],
                                )
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        headerColor),
                                  ),
                                ),
                        ),
                        title: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            userProvider.user.sFirstName +
                                ' ' +
                                userProvider.user.sLastName,
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[900]),
                          ),
                        ),
                        description: Container(
                          margin: EdgeInsets.only(top: 3),
                          child: Text(
                            'Account Information',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[600]),
                          ),
                        ),
                        leading: Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                          ),
                          height: 60,
                          width: 60,
                          child: ClipOval(
                            child: userProvider.user.sProfilePicture.isEmpty
                                ? Image.asset(
                                    'assets/images/friend1.jpg',
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    userProvider.user.sProfilePicture,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        onPressed: (context) async {
                          await AnalitysService().sendAnalyticsEvent(
                              'create_listing_from_more_click', {
                            "screen_view": "more_screen",
                            "item_id": 'new_listing',
                            'item_type': 'empty'
                          });
                          String userName =
                              await _userRepository.readKey('user_name');
                          userName == 'guess'
                              ? showDialogAlert(context, "Subscribe now!")
                              : goSettings();
                        },
                      ),
                      SettingsTile(
                        title: Text(''),
                        leading: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: 200,
                          margin: EdgeInsets.only(
                            top: 10,
                          ),
                          padding: EdgeInsets.only(top: 0),
                          child: Card(
                            elevation: 5,
                            borderOnForeground: true,
                            shadowColor: Colors.black.withOpacity(0.3),
                            color: Colors.white,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(1.0),
                                  ],
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.only(top: 0, left: 20),
                                      child: Text(
                                        'Your Network',
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _button(
                                          userProvider.user.nConnections
                                              .toString(),
                                          "Connections",
                                          Icons.add,
                                          headerColor,
                                          () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserNetworkComponent(),
                                              ),
                                            );
                                          },
                                        ),
                                        userProvider.user.nRequests > 0
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 0),
                                                child: Badge(
                                                  backgroundColor: headerColor,
                                                  offset: Offset(0, 18),
                                                  alignment: Alignment.topRight,
                                                  label: Text(
                                                    '*',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  child: _button(
                                                    userProvider.user.nRequests
                                                        .toString(),
                                                    "Invitations",
                                                    Icons.add,
                                                    headerColor,
                                                    () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserNetworkComponent(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  textColor: Colors.white,
                                                ),
                                              )
                                            : _button(
                                                userProvider.user.nRequests
                                                    .toString(),
                                                "Invitations",
                                                Icons.add,
                                                headerColor,
                                                () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserNetworkComponent(),
                                                    ),
                                                  );
                                                },
                                              ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserNetworkComponent(),
                                              ),
                                            );
                                          },
                                          child: Image.asset(
                                            'assets/images/referral.png',
                                            height: 130,
                                            width: 170,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        onPressed: (context) async {
                          String userName =
                              await _userRepository.readKey('user_name');
                          userName == 'guess'
                              ? showDialogAlert(context, "Subscribe now!")
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserNetworkComponent(),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Container(
                        margin: EdgeInsets.only(top: 25, bottom: 20),
                        child: Text(
                          'Features',
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold),
                        )),
                    margin: EdgeInsetsDirectional.all(0),
                    tiles: [
                      SettingsTile(
                        trailing: Container(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        title: Container(
                          child: Text(
                            'Add New Property',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[800]),
                          ),
                        ),
                        onPressed: (context) async {
                          await AnalitysService().sendAnalyticsEvent(
                              'create_listing_from_more_click', {
                            "screen_view": "more_screen",
                            "item_id": 'new_listing',
                            'item_type': 'empty'
                          });
                          String userName =
                              await _userRepository.readKey('user_name');
                          userName == 'guess'
                              ? showDialogAlert(context, "Subscribe now!")
                              : Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CreationWizard(
                                        title: 'New Listing Creation',
                                        fromDraft: false,
                                        listing: this.newListing,
                                        enableComponents: true,
                                        cleanWizardOffside: true,
                                        validAddress: false,
                                        selectedIndex: 0),
                                  ),
                                );
                        },
                      ),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                      SettingsTile(
                        enabled: userProvider.user.bReferralAvailable,
                        trailing: isNavigatingReferal == false
                            ? Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: headerColor,
                              )
                            : Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      headerColor),
                                ),
                              ),
                        title: Text(
                          'Seller Benefit Program',
                          style: TextStyle(fontSize: 20, color: headerColor),
                        ),
                        onPressed: (context) async {
                          String userName =
                              await _userRepository.readKey('user_name');
                          userName == 'guess'
                              ? showDialogAlert(context, "Subscribe now!")
                              : goToReferal();
                        },
                      ),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    margin: EdgeInsetsDirectional.all(0),
                    tiles: [
                      SettingsTile(
                        trailing: Container(
                          margin: EdgeInsets.only(top: 14),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        title: Container(
                          margin: EdgeInsets.only(top: 14),
                          child: Text(
                            'Feedback',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[800]),
                          ),
                        ),
                        onPressed: (context) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (_) => ReviewScreen(),
                          ))
                              .then(
                            (value) {
                              if (value != null) {
                                final flush = Flushbar(
                                  message: value
                                      ? 'Review Submitted Successfully. Thank you!'
                                      : 'Review Not Submitted. Please try again later.',
                                  flushbarStyle: FlushbarStyle.FLOATING,
                                  margin: EdgeInsets.all(8.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: 28.0,
                                    color:
                                        value ? Colors.blue[800] : Colors.red,
                                  ),
                                  duration: Duration(seconds: 26),
                                  leftBarIndicatorColor:
                                      value ? Colors.blue[800] : Colors.red,
                                );
                                flush.show(context);
                              }
                            },
                          );
                        },
                      ),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                      SettingsTile(
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          title: Text(
                            'Contact Us',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[800]),
                          ),
                          onPressed: (context) async {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ContactUs()),
                            );
                          }),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                      SettingsTile(
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          title: Text(
                            'Share App',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[800]),
                          ),
                          onPressed: (context) async {
                            String branchCode =
                                await _userRepository.readKey('branchCode');
                            Share.share(
                                branchCode.isNotEmpty
                                    ? branchCode
                                    : 'https://zeamless.app.link/4U1m2GePJBb',
                                subject: 'Zeamless App.');
                          }),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SettingsSection(
                    margin: EdgeInsetsDirectional.all(0),
                    tiles: [
                      SettingsTile(
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: (context) async {
                          final Uri _url =
                              Uri.parse('https://zeamless.io/#/terms');
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            // can't launch url
                          }
                        },
                        title: Text('Terms Of Use',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[800])),
                      ),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(top: 0, bottom: 0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                      SettingsTile(
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: (context) async {
                          final Uri _url =
                              Uri.parse('https://zeamless.io/#/privacy');
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            // can't launch url
                          }
                        },
                        title: Text(
                          'Privacy Policy',
                          style:
                              TextStyle(fontSize: 20, color: Colors.grey[800]),
                        ),
                      ),
                      SettingsTile(
                        title: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 0, bottom: 0),
                            margin: EdgeInsets.only(
                              top: 0,
                              bottom: 0,
                            ),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                      SettingsTile(
                        onPressed: (context) async {
                          showLogoutDialog(context, 'Logout');
                        },
                        title: Text(
                          'Logout',
                          style: TextStyle(fontSize: 20, color: headerColor),
                        ),
                        leading: Icon(
                          Icons.logout,
                          size: 28,
                          color: headerColor,
                        ),
                      ),
                    ],
                  ),
                  CustomSettingsSection(
                    child: GestureDetector(
                      onTap: () async {},
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Zeamless App',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Color(0xFF777777),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Version: 1.1.2',
                            style: TextStyle(color: Color(0xFF777777)),
                          ),
                          SizedBox(height: 15)
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  goSettings() async {
    if (isNavigatingProfile == false) {
      setState(() {
        isNavigatingProfile = true;
      });
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (_) => AccountProfileSettings(),
        ),
      )
          .then(
        (value) async {
          setState(() {
            isNavigatingProfile = false;
          });
          if (value == true) {
            setState(() {
              showLoading = true;
            });
            context.read<MoreBloc>().add(const MoreSubmitted());
          }
        },
      );
    }
  }

  goToReferal() async {
    if (isNavigatingReferal == false) {
      setState(() {
        isNavigatingReferal = true;
      });

      String invitationCode = await _userRepository.readKey('invitationCode');
      String branchCode = await _userRepository.readKey('branchCode');

      Navigator.of(context)
          .push(
        MaterialPageRoute(
            builder: (_) => ReferalScreen(
                branchCode: branchCode, invitationCode: invitationCode)),
      )
          .then(
        (value) {
          setState(() {
            isNavigatingReferal = false;
          });
        },
      );
    }
  }

  showDialogAlert(BuildContext context, String title) {
    Widget cancelButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await _userRepository.deleteToken('user_name');
        await _userRepository.writeToken('user_name', 'finished');
        Navigator.pop(dialogContext!);
        final _storage = FlutterSecureStorage();
        await _storage.deleteAll();
        context.read<MoreBloc>().add(const MoreSubmitted());
      },
    );
    Widget continueButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(
          'Please subscribe to our platform to get full access to the market.'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  showLogoutDialog(BuildContext context, String title) {
    Widget cancelButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: headerColor, fontSize: 16, fontWeight: FontWeight.bold)),
      onPressed: () async {
        setState(() {
          showLoading = true;
        });
        Navigator.pop(dialogContext!);
        final _storage = FlutterSecureStorage();
        await _storage.deleteAll();
        context.read<MoreBloc>().add(const MoreSubmitted());
      },
    );
    Widget continueButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
              color: buttonsColor, fontSize: 16, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.pop(dialogContext!);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title,
          style: TextStyle(
              color: buttonsColor, fontSize: 21, fontWeight: FontWeight.bold)),
      content: Text(
          'Are you sore you want to logout? You will not be able to access your account until you login again.',
          style: TextStyle(color: buttonsColor, fontSize: 17)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  Widget buildLoadingPage() {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Closing Session...',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(String number, String label, IconData icon, Color color,
      void Function()? onTap) {
    return Container(
      margin: EdgeInsets.only(left: 13, top: 12, bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                number,
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 8.0,
                    )
                  ]),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  initialData() {
    setState(() {
      this.newListing = new Listing(
          uLystingId: '-1',
          sTitle: '',
          nFirstPrice: 0,
          nCurrentPrice: 0,
          sPropertyAddress: '',
          bKeepAddressPrivate: false,
          sPropertyDescription: '',
          sPropertyType: '',
          nBedrooms: 0,
          nBathrooms: 0,
          nHalfBaths: 0,
          nSqft: 0,
          nLotSize: 0.00,
          nYearBuilt: 1900,
          sCoolingType: '',
          sHeatingType: '',
          sParkingType: '',
          nCoveredParking: 0,
          sVacancyType: '',
          nEarnestMoney: 0,
          sEarnestMoneyTerms: '',
          sAdditionalDealTerms: ' ',
          sLotLegalDescription: ' ',
          nNumberofUnits: 1,
          sShowingDateTime: '',
          sZipCode: '',
          imagesAssets: [],
          sResourcesUrl: [],
          sAmenities: [],
          sCompsInfo: [],
          sLatitud: 0,
          sLongitud: 0,
          sApartmentNumber: '',
          sUnitArea: '',
          sTypeOfSell: '',
          sPropertyCondition: '',
          sIsInMLS: '',
          nMonthlyHoaFee: 0,
          sContactName: '',
          sContactNumber: '',
          sContactEmail: '',
          nEstARV: 0,
          sIsOwner: '',
          bComparableAvailable: false,
          bNetworkBlast: false,
          bBoostOnPlatforms: false,
          sTags: [],
          sLystingCategory: '');
    });
  }
}
