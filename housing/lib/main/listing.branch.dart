import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_view.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/mls_view.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/repository/store/auth_view/Listing/Listing_event.dart';
import 'package:zipcular/repository/store/auth_view/listing/listing_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/repository/store/splash/loading_animation.widget.dart';

class ListingBranch extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => ListingBranch());
  }

  @override
  State<ListingBranch> createState() => _ListingBranchState();
}

class _ListingBranchState extends State<ListingBranch> {
  bool isLogin = false;
  bool isLoading = false;
  UserRepository _userRepository = UserRepository();

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
    return Container(
      child: BlocProvider(
        create: (context) {
          return ListingBloc(
            authenticationRepository:
                RepositoryProvider.of<AuthenticationRepository>(context),
          );
        },
        child: isLoading == true
            ? Center(
                child: Container(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                  ),
                ),
              )
            : FutureBuilder<Listing>(
                future: requestListing,
                builder:
                    (BuildContext context, AsyncSnapshot<Listing> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
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
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    headerColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If there is an error, display an error message.
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.signal_wifi_off,
                              size: 110, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(fontSize: 24, color: buttonsColor),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 32),
                              backgroundColor: headerColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<ListingBloc>()
                                  .add(ListingSubmitted());
                            },
                            child: Text('Retry',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Once data is loaded, display it.
                    return snapshot.data!.bHasZeamlessUser! == false
                        ? MLSView(
                            invitationCode: '',
                            listing: snapshot.data as Listing,
                            callback: (value) {},
                            isMyListing: false,
                            routing: true,
                            callbackRouting: (data) async {
                              await _userRepository
                                  .deleteToken('from_branch_listing');
                              await _userRepository
                                  .deleteToken('from_branch_referal');
                              setState(() {
                                isLoading = true;
                              });
                              context
                                  .read<ListingBloc>()
                                  .add(ListingSubmitted());
                            },
                          )
                        : ListingView(
                            invitationCode: '',
                            listing: snapshot.data as Listing,
                            callback: (value) {},
                            isMyListing: false,
                            routing: true,
                            callbackRouting: (data) async {
                              await _userRepository
                                  .deleteToken('from_branch_listing');
                              await _userRepository
                                  .deleteToken('from_branch_referal');
                              context
                                  .read<ListingBloc>()
                                  .add(ListingSubmitted());
                            },
                          );
                  }
                },
              ),
      ),
    );
  }

  final Future<Listing> requestListing = Future<Listing>.delayed(
    const Duration(seconds: 0),
    () async {
      UserRepository _userRepository = UserRepository();
      Listing listing = Listing();
      String branchListing =
          await _userRepository.readKey('from_branch_listing');

      if (branchListing.isNotEmpty) {
        try {
          ResponseService result = await ListingFacade().getlysting(
            branchListing,
            'Live',
            false,
          );

          if (result.bSuccess!) {
            listing = result.data as Listing;
            listing.sSearch = branchListing;
            listing.sLogicStatus = 'Live';
          }
        } catch (e) {
          await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        }
      }
      return listing;
    },
  );
}
