import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/mls.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/single_family.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/saves.facade.dart';
import '../../../../models/map/pin_info.dart';
import '../listing-preview/lot.component.dart';
import '../listing-preview/multi_family.component.dart';

class MapPreviewComponent extends StatefulWidget {
  bool showProfile;
  double? pinPillPosition;
  PinInformation? currentlySelectedPin;
  Listing? listing;
  ValueChanged<Tuple2<CustomerModel, Listing>> callbackOpenProfile;

  MapPreviewComponent(
      {Key? key,
      double? pinPillPosition,
      PinInformation? currentlySelectedPin,
      ValueChanged<Tuple2<CustomerModel, Listing>>? callbackOpenProfile,
      Listing? listing,
      bool? refresh,
      bool? showProfile})
      : pinPillPosition = pinPillPosition!,
        currentlySelectedPin = currentlySelectedPin!,
        listing = listing!,
        callbackOpenProfile = callbackOpenProfile!,
        showProfile = showProfile!,
        super(key: key);

  @override
  State<MapPreviewComponent> createState() => _MapPreviewComponentState();
}

class _MapPreviewComponentState extends State<MapPreviewComponent> {
  BuildContext? dialogContext;
  late Widget _child = Container();
  bool reset = false;

  @override
  void initState() {
    this._child = loadCard(context);
    super.initState();
  }

  @override
  void didUpdateWidget(MapPreviewComponent oldWidget) {
    if (oldWidget.listing?.sSearch != null) {
      this._child = this.widget.listing?.sSearch != oldWidget.listing?.sSearch
          ? Container()
          : loadCard(context);
      reset = true;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return AnimatedPositioned(
        bottom: widget.pinPillPosition,
        right: 0,
        left: 0,
        duration: Duration(milliseconds: 200),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            child: this._child,
            onDoubleTap: () {
              this.widget.pinPillPosition = -500;
              this.widget.currentlySelectedPin!.callback!(-500);
            },
          ),
        ),
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
      return Container();
    }
  }

  loadCard(BuildContext context) {
    try {
      if (this.widget.listing!.sPropertyType == null) {
        return Container();
      } else {
        if (this.widget.listing!.bHasZeamlessUser == false) {
          return new PrevMLS(
              showStory: true,
              item: this.widget.listing,
              callback: (val) async {
                if (val.item2 == true) {
                  await addFavorite(context, val);
                } else {
                  await deleteFavorite(context, val);
                }
              },
              callbackRemoveListing: (val) {},
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              },
              isEditMode: false,
              isPreviewFavorite: false);
        } else {
          switch (this.widget.listing!.sPropertyType!) {
            case 'Single Family':
              return new PrevSingleFamily(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            case 'Apartment':
              return new PrevSingleFamily(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            case 'Condo':
              return new PrevSingleFamily(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            case 'Townhome':
              return new PrevSingleFamily(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            case 'Lot':
              return new PrevLot(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            case 'Multi-Unit Complex':
              return new PrevMultiFamily(
                  showProfile: widget.showProfile,
                  showStory: true,
                  item: this.widget.listing,
                  callback: (val) async {
                    if (val.item2 == true) {
                      await addFavorite(context, val);
                    } else {
                      await deleteFavorite(context, val);
                    }
                  },
                  callbackRemoveListing: (val) {},
                  callbackOpenProfile: (value) {
                    this.widget.callbackOpenProfile(value);
                  },
                  isEditMode: false,
                  isPreviewFavorite: false);
            default:
              return Container();
          }
        }
      }
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
  }

  addFavorite(BuildContext context, Tuple2<Listing, bool> val) async {
    ResponseService response = await SavesFacade().addFavoriteLising(val.item1);
    if (response.hasConnection == false) {
      final flush = Flushbar(
        message: 'No Internet Connection',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.wifi_off_outlined,
          size: 28.0,
          color: headerColor,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: headerColor,
      );
      flush.show(context);
    }
  }

  deleteFavorite(BuildContext context, Tuple2<Listing, bool> val) async {
    ResponseService response =
        await SavesFacade().deleteFavoriteLising(val.item1);
    if (response.hasConnection == false) {
      final flush = Flushbar(
        message: 'No Internet Connection',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.wifi_off_outlined,
          size: 28.0,
          color: headerColor,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: headerColor,
      );
      flush.show(context);
    }
  }
}
