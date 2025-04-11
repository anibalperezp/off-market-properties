import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story/story_page_view.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/main/main.auth.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_view.component.dart';
import 'package:zipcular/containers/main_screen/my_listings/update.my_listings.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class PrevMultiFamily extends StatefulWidget {
  final Listing item;
  ValueChanged<Tuple2<Listing, bool>> callback;
  bool isPreviewFavorite;
  bool isEditMode;
  ValueChanged<String> callbackRemoveListing;
  ValueChanged<Tuple2<CustomerModel, Listing>> callbackOpenProfile;
  bool showStory;
  bool showProfile;
  PrevMultiFamily(
      {Key? key,
      Listing? item,
      double? parentHeigh,
      ValueChanged<Tuple2<Listing, bool>>? callback,
      bool? isPreviewFavorite,
      bool? isEditMode,
      ValueChanged<String>? callbackRemoveListing,
      ValueChanged<Tuple2<CustomerModel, Listing>>? callbackOpenProfile,
      bool? showStory,
      bool? showProfile})
      : item = item!,
        callback = callback!,
        isPreviewFavorite = isPreviewFavorite!,
        isEditMode = isEditMode!,
        callbackRemoveListing = callbackRemoveListing!,
        callbackOpenProfile = callbackOpenProfile!,
        showStory = showStory!,
        showProfile = showProfile!,
        super(key: key);

  @override
  _PrevMultiFamilyState createState() => _PrevMultiFamilyState();
}

class _PrevMultiFamilyState extends State<PrevMultiFamily> {
  BuildContext? dialogContext;
  UserRepository userRepository = new UserRepository();
  Widget? widgetState;
  final formatter = new NumberFormat("#,###", "en_US");
  Color colorListingStatus = Colors.white;
  String? _selected;
  bool loadingEdit = false;
  bool loadingChangeStatus = false;
  bool loadingDelete = false;
  bool loadingProfile = false;
  List<String> values = ["For Sale", "Pending", "Sold"];
  List<String> selectedList = List<String>.empty(growable: true);
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  String changeStatusSelected = '';

  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;

  @override
  void initState() {
    _selected = widget.item.sLystingStatus;
    if (_selected != null) {
      values = values
          .where((e) => e.toUpperCase() != _selected!.toUpperCase())
          .cast<String>()
          .toList();
    }
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
    super.initState();
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      this.widget.item.bIsNew =
          this.widget.item.bIsNew == null ? false : this.widget.item.bIsNew;
      widgetState = previewListing();
    });
    return widgetState!;
  }

  Widget previewListing() {
    switch (this.widget.item.sLystingStatus) {
      case 'For Sale':
        colorListingStatus = Color.fromARGB(255, 21, 96, 25);
        break;
      case 'Pending':
        colorListingStatus = Color.fromARGB(255, 227, 148, 22);
        break;
      case 'Sold':
        colorListingStatus = Color.fromARGB(255, 152, 12, 12);
        break;
    }
    Widget widgetReturn = Container();
    try {
      widgetReturn = GestureDetector(
        onTap: () async {
          String invitationCode =
              await userRepository.readKey('invitationCode');
          await AnalitysService().sendAnalyticsEvent('listing_open_tot_click', {
            "screen_view": "listing_preview_screen",
            "item_id": this.widget.item.sSearch,
            'item_type': this.widget.item.sPropertyType
          });
          await AnalitysService()
              .setCurrentScreen('listing_screen', 'MultiUnix');
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 900),
              child: ListingView(
                  invitationCode: invitationCode,
                  listing: this.widget.item,
                  callback: (value) => checkFavorite(value),
                  isMyListing: this.widget.isEditMode,
                  routing: false,
                  callbackRouting: (value) {}),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3),
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.bottomLeft, //Here
                    children: [
                      this.widget.item.sResourcesUrl.length == 0
                          ? Image.asset(
                              "assets/images/house-test.jpeg",
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            )
                          : this.widget.item.sResourcesUrl.length == 1 &&
                                  this.widget.showStory == true
                              ? showStory(context)
                              : Image.network(
                                  this.widget.item.sResourcesUrl[0],
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                      Visibility(
                        visible: this.widget.showProfile == true,
                        child: GestureDetector(
                          child: Container(
                            height: 60,
                            width: 60,
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Center(
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: loadingProfile == false
                                    ? CircleAvatar(
                                        radius: 70,
                                        child: ClipOval(
                                          child: widget
                                                  .item.sProfilePicture!.isEmpty
                                              ? Image.asset(
                                                  'assets/images/friend1.jpg',
                                                  height: 150,
                                                  width: 150,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  widget.item.sProfilePicture!,
                                                  height: 150,
                                                  width: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      )
                                    : Container(
                                        height: 35,
                                        width: 35,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  headerColor),
                                        ),
                                      ),
                              ),
                            ),
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
                          ),
                          onTap: () async {
                            setState(() {
                              loadingProfile = true;
                            });
                            //Call sliding_up_panel2
                            ResponseService response = await ListingFacade()
                                .getCustomerProfile(
                                    this.widget.item.sInvitationCode!);
                            if (response.hasConnection == false) {
                              final flush = Flushbar(
                                message: 'No Internet Connection',
                                flushbarStyle: FlushbarStyle.FLOATING,
                                margin: EdgeInsets.all(8.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                icon: Icon(
                                  Icons.wifi_off_outlined,
                                  size: 28.0,
                                  color: headerColor,
                                ),
                                duration: Duration(seconds: 2),
                                leftBarIndicatorColor: headerColor,
                              );
                              setState(() {
                                loadingProfile = false;
                              });
                              flush.show(context);
                            } else {
                              setState(() {
                                loadingProfile = false;
                              });
                              CustomerModel customer =
                                  response.data as CustomerModel;
                              customer.sInvitationCode =
                                  this.widget.item.sInvitationCode;
                              widget.callbackOpenProfile(
                                  Tuple2<CustomerModel, Listing>(
                                      customer, widget.item));
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(top: 0, bottom: 2),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Row(
                    children: [
                      Text(
                        this.widget.item.sLystingStatus!,
                        style: TextStyle(
                            fontSize: 20,
                            color: colorListingStatus,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        getTypeOfSell(widget.item.sTypeOfSell!),
                        style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                      ),
                      Spacer(),
                      this.widget.item.bIsNew!
                          ? Container(
                              width: 46,
                              decoration: BoxDecoration(
                                color: headerColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: headerColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "New",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Row(
                    children: [
                      Text(
                          "\$${formatter.format(this.widget.item.nCurrentPrice)}",
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 21,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 32),
                      Text(
                        this.widget.item.nPricePerSqft == null
                            ? "\$${0}/sqft"
                            : "\$${this.widget.item.nPricePerSqft}/sqft",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      GFButtonBar(
                        children: <Widget>[
                          Visibility(
                            visible: this.widget.item.sLogicStatus == 'Live' &&
                                (this.widget.item.sLystingStatus == 'Sold' ||
                                    this.widget.item.sLystingStatus ==
                                        'For Sale' ||
                                    this.widget.item.sLystingStatus ==
                                        'Pending'),
                            child: GestureDetector(
                              onTap: () async {
                                await AnalitysService().sendAnalyticsEvent(
                                  'shares_listing_tot_click',
                                  {
                                    "screen_view": "listing_preview_screen",
                                    "item_id": this.widget.item.sSearch,
                                    'item_type': this.widget.item.sPropertyType
                                  },
                                );
                                this.widget.isEditMode
                                    ? showMenuSelection(context)
                                    : await shareListing();
                              },
                              child: Icon(
                                Icons.share,
                                color: Colors.grey[700],
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(width: 1),
                          Visibility(
                            visible: this.widget.isEditMode == false,
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  if (this.widget.item.bIsFavorite == false) {
                                    this.widget.item.bIsFavorite = true;
                                  } else {
                                    this.widget.item.bIsFavorite = false;
                                  }
                                });
                                await AnalitysService().sendAnalyticsEvent(
                                    this.widget.item.bIsFavorite == true
                                        ? 'hearts_tot_add'
                                        : 'hearts_tot_remove',
                                    {
                                      "screen_view": "listing_preview_screen",
                                      "item_id": this.widget.item.sSearch,
                                      'item_type':
                                          this.widget.item.sPropertyType
                                    });
                                this.widget.callback(Tuple2(this.widget.item,
                                    this.widget.item.bIsFavorite!));
                              },
                              child: this.widget.item.bIsFavorite!
                                  ? Icon(
                                      Icons.favorite,
                                      color: headerColor,
                                      size: 30,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.heart,
                                      color: headerColor,
                                      size: 30,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                this.widget.item.sPropertyAddress!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[800]),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                this.widget.item.nNumberofUnits.toString(),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'units',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                this.widget.item.sLotSize!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                this.widget.item.nYearBuilt.toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                                size: 15.0,
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            children: [
                              Text(
                                this.widget.item.sPropertyType! + ', ',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                this.widget.item.sPropertyCondition! +
                                    ' Condition',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          if (this.widget.item.sTags!.length > 0)
                            SizedBox(
                              height: 7,
                            ),
                          // Add wrap clips
                          if (this.widget.item.sTags!.length > 0)
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  .85, // Set width to card width minus padding
                              child: Wrap(
                                spacing: 5,
                                runSpacing:
                                    10, // Positive value to wrap tags to next line
                                children: [
                                  for (var tag in this.widget.item.sTags!)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      margin: EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          Visibility(
                            visible: this.widget.item.sTitle!.isNotEmpty,
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          Visibility(
                            visible: this.widget.item.sTitle!.isNotEmpty,
                            child: Text(
                              this.widget.item.sTitle!.isNotEmpty
                                  ? this.widget.item.sTitle!.length > 30
                                      ? '"' +
                                          this
                                              .widget
                                              .item
                                              .sTitle!
                                              .substring(0, 30)
                                              .toUpperCase() +
                                          '..."'
                                      : this.widget.item.sTitle!
                                  : '',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Visibility(
                            visible: this.widget.isEditMode == true &&
                                (widget.item.sLogicStatus == 'Live' ||
                                    widget.item.sLogicStatus == 'Draft' ||
                                    widget.item.sLogicStatus ==
                                        'ActionReqSt2' ||
                                    widget.item.sLogicStatus ==
                                        'LiveActionReqSt5'),
                            child: SizedBox(
                              height: 7,
                            ),
                          ),
                          Visibility(
                            visible: this.widget.isEditMode == true,
                            child: Row(
                              children: [
                                Visibility(
                                  visible:
                                      this.widget.item.sLogicStatus == 'Live' &&
                                          (this.widget.item.sLystingStatus ==
                                                  'Sold' ||
                                              this.widget.item.sLystingStatus ==
                                                  'For Sale' ||
                                              this.widget.item.sLystingStatus ==
                                                  'Pending'),
                                  child: loadingChangeStatus == true
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(headerColor),
                                          ),
                                        )
                                      : ElevatedButton(
                                          child: Text("Change Status",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: headerColor,
                                            elevation: 5,
                                            minimumSize: Size(100, 30),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            this.changeStatusDialog(context,
                                                'Action', 'Select new status');
                                          },
                                        ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Visibility(
                                    visible: widget.item.sLogicStatus ==
                                            'Live' ||
                                        widget.item.sLogicStatus == 'Draft' ||
                                        widget.item.sLogicStatus ==
                                            'ActionReqSt2' ||
                                        widget.item.sLogicStatus ==
                                            'LiveActionReqSt5',
                                    child: loadingEdit == true
                                        ? Container(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(headerColor),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () async {
                                              await requestListing();
                                            },
                                            child: GFAvatar(
                                              backgroundColor: headerColor,
                                              size: 20,
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ))),
                                SizedBox(width: 10),
                                Visibility(
                                  visible: widget.item.sLogicStatus == 'Live' ||
                                      widget.item.sLogicStatus == 'Draft' ||
                                      widget.item.sLogicStatus ==
                                          'ActionReqSt2' ||
                                      widget.item.sLogicStatus ==
                                          'LiveActionReqSt5',
                                  child: loadingDelete == true
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(headerColor),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            deleteDraftDialog(context, 'Alert',
                                                'Are you sure you want to delete this listing? There will be a 15-day waiting period before you can repost this listing. We strive to keep new listings relevant.');
                                          },
                                          child: GFAvatar(
                                            backgroundColor: Colors.red,
                                            size: 20,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Future.delayed(
        Duration.zero,
        () async {
          await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        },
      );
    }
    return widgetReturn;
  }

  deleteDraft(String sSearch, String sLogicStatus) async {
    setState(() {
      loadingDelete = true;
    });

    ResponseService response =
        await ListingFacade().deleteListing(sSearch, sLogicStatus);

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
    } else {
      widget.callbackRemoveListing(sSearch);
    }

    setState(() {
      loadingDelete = false;
    });
  }

  deleteDraftDialog(BuildContext context, String title, String content) {
    Widget noButton = TextButton(
        child: Text("No",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.pop(dialogContext!);
        });
    Widget yesButton = TextButton(
        child: Text("Yes",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.pop(dialogContext!);
          deleteDraft(widget.item.sSearch!, widget.item.sLogicStatus!);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [noButton, yesButton],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  checkFavorite(bool value) async {
    setState(() {
      if (value) {
        this.widget.item.bIsFavorite = value;
      } else {
        this.widget.item.bIsFavorite = value;
      }
      this
          .widget
          .callback(Tuple2(this.widget.item, this.widget.item.bIsFavorite!));
    });
  }

  showDialogAlert(BuildContext context, String title) {
    Widget cancelButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await userRepository.deleteToken('user_name');
        await userRepository.writeToken('user_name', 'finished');
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainAuth(),
          ),
        );
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

  requestListing() async {
    setState(() {
      loadingEdit = true;
    });
    try {
      ResponseService result = await ListingFacade().getlysting(
          this.widget.item.sSearch!,
          this.widget.item.sLogicStatus!,
          this.widget.isEditMode);

      if (result.hasConnection == false) {
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

      if (result.bSuccess!) {
        setState(() {
          loadingEdit = false;
        });
        int index = propTypes.indexOf(widget.item.sPropertyType!);
        Listing listing = result.data as Listing;
        listing.sSearch = this.widget.item.sSearch;
        listing.sLogicStatus = this.widget.item.sLogicStatus;
        listing.nFirstPrice = this.widget.item.nCurrentPrice;
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => UpdateListing(
                    title: 'Update Listing',
                    listingObj: listing,
                    selectedIndex: index + 1)))
            .then((value) {
          widget.callbackRemoveListing(listing.sSearch!);
        });
      }
      setState(() {
        loadingEdit = false;
      });
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  changeStatus(String sSearch, String sLogicStatus, bool bKeepAddressPrivate,
      String sTypeOfSell) async {
    setState(() {
      loadingChangeStatus = true;
    });

    ResponseService response = await ListingFacade().changeStatusListing(
        sSearch, sLogicStatus, bKeepAddressPrivate, sTypeOfSell);
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
    } else {
      final flush = Flushbar(
        message: 'Channge Status Success',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.check_circle_outline,
          size: 28.0,
          color: Colors.green,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.green,
      );
      flush.show(context);
      widget.callbackRemoveListing(sSearch);
    }

    setState(() {
      loadingChangeStatus = false;
    });
  }

  changeStatusDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      elevation: 10,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 30),
          padding: EdgeInsets.all(20),
          height: 240,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 30),
                Text('Change Listing Status',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Container(
                  constraints: BoxConstraints(
                      maxHeight: 30), // Set the maximum height here
                  child: DropdownSearch<String>(
                      popupProps: PopupProps.dialog(
                        dialogProps: DialogProps(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        showSearchBox: false,
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            constraints: BoxConstraints(
                                maxHeight: 50), // Set the minimum height
                            child: ListTile(
                              title: Text(item ?? ''),
                              selected: isSelected,
                            ),
                          );
                        },
                      ),
                      items: [...this.values],
                      validator: (String? value) {
                        if (value == '0') {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          this.changeStatusSelected = newValue!;
                        });
                      },
                      selectedItem: this.changeStatusSelected),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    elevation: 5,
                    minimumSize: Size(100, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Confirm',
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                  onPressed: () {
                    Navigator.pop(context);
                    changeStatus(
                        widget.item.sSearch!,
                        changeStatusSelected,
                        widget.item.bKeepAddressPrivate!,
                        widget.item.sTypeOfSell!);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  showStory(BuildContext bContext) {
    return StoryPageView(
      pageLength: this.widget.item.sResourcesUrl.length,
      initialStoryIndex: (indexH) {
        return 0;
      },
      storyLength: (int pageIndex) {
        return this.widget.item.sResourcesUrl.length;
      },
      initialPage: 0,
      indicatorAnimationController: indicatorAnimationController,
      indicatorPadding: EdgeInsets.only(top: 0),
      indicatorDuration: Duration(seconds: 2),
      indicatorHeight: 3,
      indicatorVisitedColor: Colors.white,
      indicatorUnvisitedColor: Colors.grey[700]!,
      showShadow: true,
      gestureItemBuilder: (context, pageIndex, storyIndex) => GestureDetector(
        onLongPressDown: (value) {
          indicatorAnimationController.value = IndicatorAnimationCommand.pause;
        },
        onLongPressUp: () {
          indicatorAnimationController.value = IndicatorAnimationCommand.resume;
        },
      ),
      itemBuilder: (context, pageIndex, storyIndex) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
            Positioned.fill(
              child: Image.network(
                this.widget.item.sResourcesUrl[storyIndex],
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: 100,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Center(
                      child: Text(
                        'Image ${storyIndex + 1} - ${this.widget.item.sResourcesUrl.length}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showMenuSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Visibility(
              visible:
                  this.widget.isEditMode, // Change Visibility to Facebook Post
              child: ListTile(
                onTap: () async {
                  Navigator.pop(context, true);
                  await shareOnFacebook();
                },
                leading:
                    Icon(FontAwesomeIcons.facebookSquare, color: Colors.blue),
                title: Text('Post to Facebook Groups'),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context, false);
                await shareListing();
              },
              leading: Icon(FontAwesomeIcons.share),
              title: Text('Share Property'),
            ),
          ],
        );
      },
    );
  }

  shareListing() async {
    if (widget.item.sSocialShareLink!.isEmpty) {
      final link = await createSocialShare(widget.item);
      final response =
          await ListingFacade().savePreviewShare(widget.item.sSearch!, link);
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
      } else {
        setState(() {
          widget.item.sSocialShareLink = link;
        });
      }
    }
    Share.share(widget.item.sSocialShareLink!, subject: 'Zeamless App.');
  }

  shareOnFacebook() async {
    // Here, you would use the Facebook SDK or the appropriate package method to share content.
    // This is a placeholder for demonstration purposes.
    try {
      final quote = 'Zeamless App';
      if (widget.item.sSocialShareLink!.isEmpty) {
        final link = await createSocialShare(widget.item);
        final response =
            await ListingFacade().savePreviewShare(widget.item.sSearch!, link);
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
        } else {
          setState(() {
            widget.item.sSocialShareLink = link;
          });
        }
      }
      var url = Uri.https('www.facebook.com', '/dialog/feed', {
        'app_id': '220621334051031',
        'display': 'page',
        'caption': quote,
        'name': quote,
        'description': 'Some description here',
        "link": widget.item.sSocialShareLink!,
        'quote': quote
        // "quote": 'Hello'
      });
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // can't launch url
      }
    } catch (e) {
      // Handle any errors here
      print('Error sharing content: $e');
    }
  }
}
