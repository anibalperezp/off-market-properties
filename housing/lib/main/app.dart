import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/notification.global.dart';
import 'package:zipcular/firebase_options.dart';
import 'package:zipcular/main/partial-view/app-view.component.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/repository/store/auth_view/authentication/authentication_bloc.dart';
import 'package:zipcular/repository/store/auth_view/authentication/authentication_state.dart';
import 'dart:async';
import 'package:zipcular/repository/store/authentication_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  final UserRepository _userRepository = UserRepository();
  late StreamSubscription<Map>? streamSubscriptionDeepLink;
  //Init state
  late FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late AuthenticationBloc _bloc;
  String branchReferal = '';
  String branchListing = '';

  @override
  void initState() {
    // Initialize the Bloc instance
    _bloc = AuthenticationBloc(
      authenticationRepository: _authenticationRepository,
      userRepository: _userRepository,
    );

    // Initialize branch.io
    Future.delayed(Duration.zero, () async {
      // Register for notification
      await registerNotification();

      // Check for initial firebase message
      await checkForInitialMessage();

      // Initialize branch.io
      await listenDeepLinkData(context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        if (message != null) {
          getNotification(message);
        }
      } catch (e) {
        print(e);
      }
    });

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        create: (_) => _bloc,
        child: AppView(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration.zero, () async {
        // Initialize branch.io
        await listenDeepLinkData(context);
      });
      // You can perform additional actions when the app becomes active here
    }
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _onLayoutDone(_) {
    Future.delayed(Duration.zero, () async {
      // Initialize branch.io
      await listenDeepLinkData(context);
    });
  }

  /// Initialize deep link data
  /// Use own data
  /// For more info, visit https://help.branch.io/developers-hub/docs/flutter-sdk-api-reference
  listenDeepLinkData(BuildContext context) async {
    streamSubscriptionDeepLink =
        FlutterBranchSdk.initSession().listen((data) async {
      final email = await _userRepository.readKey('email');
      final password = await _userRepository.readKey('password');
      if (data.containsKey(BranchConstants.BRANCH_LISTING)) {
        // If the user has listing, Navigate to Listing Screen
        String branchFromListing = data[BranchConstants.BRANCH_LISTING];
        await _userRepository.writeToken(
            'from_branch_listing', branchFromListing);

        String branchFromReferal = data[BranchConstants.BRANCH_REFERAL];
        await _userRepository.writeToken(
            'from_branch_referal', branchFromReferal);
        // Reset block listener
        if (email.isNotEmpty && password.isNotEmpty) {
          _bloc.emit(AuthenticationState.quickAccessListing());
          // Create a new instance of the Bloc
          _bloc = AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository,
          );
        }
      } else if (data.containsKey(BranchConstants.BRANCH_REFERAL)) {
        // If the user has referal, Navigate Profile Screen
        String branchFromReferal = data[BranchConstants.BRANCH_REFERAL];
        await _userRepository.writeToken(
            'from_branch_referal', branchFromReferal);
        // Reset block listener
        if (email.isNotEmpty && password.isNotEmpty) {
          _bloc.emit(AuthenticationState.quickAccessUser());
          // Create a new instance of the Bloc
          _bloc = AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository,
          );
        }
      }
    }, onError: (error) {
      log('${error.code} - ${error.message}');
    });
  }

  /// Firebase Messaging
  /// Use own data
  ///
  checkForInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      getNotification(message);
    }
  }

  Future<void> registerNotification() async {
    try {
      // 3. On iOS, this helps to take the user permissions
      if (_messaging != null) {
        NotificationSettings settings = await _messaging!.requestPermission(
          alert: true,
          badge: true,
          provisional: false,
          sound: true,
          carPlay: true,
          criticalAlert: true,
          announcement: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('User granted permission');

          // Handling Background Messages
          FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackground);

          // Handling Notifications
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            getNotification(message);
            Future.delayed(Duration.zero, () async {
              await _userRepository.writeToken('loadMyListings', 'true');
              String counter =
                  await _userRepository.readKey('notifications_total');
              final notificationsTotal = int.parse(counter) + 1;
              await notificationsGlobalCount(notificationsTotal.toString());
            });
          });
        } else {
          print('User declined or has not accepted permission');
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
