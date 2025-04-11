import 'package:another_flushbar/flushbar.dart';
import 'package:banner_carousel/banner_carousel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/widgets/common/carousel_image_full_screen.widget.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../../models/listing/search/listing.dart';

class MLSView extends StatefulWidget {
  Listing listing;
  bool isMyListing;
  bool routing;
  ValueChanged<bool> callback;
  ValueChanged<bool> callbackRouting;
  String invitationCode = "";

  MLSView(
      {Key? key,
      bool? routing,
      Listing? listing,
      ValueChanged<bool>? callback,
      ValueChanged<bool>? callbackRouting,
      bool? isMyListing,
      String? invitationCode})
      : listing = listing!,
        callback = callback!,
        isMyListing = isMyListing!,
        routing = routing!,
        callbackRouting = callbackRouting!,
        invitationCode = invitationCode!,
        super(key: key);

  @override
  State<MLSView> createState() => _MLSViewState();
}

class _MLSViewState extends State<MLSView> with TickerProviderStateMixin {
  CustomerModel customer = CustomerModel.empty();
  List<BannerModel> listBanners = List.empty(growable: true);
  bool loading = false;
  bool loadingCall = false;
  List<String> imageList = List.empty(growable: true);
  var formatter = new NumberFormat("#,###,###", "en_US");
  BuildContext? dialogContext;
  UserRepository userRepository = new UserRepository();
  Color colorListingStatus = Colors.black;
  String sSearch = "";
  String addressP1 = "";
  String addressP2 = "";

  @override
  void initState() {
    this.sSearch = widget.listing.sSearch!;
    Future.delayed(Duration.zero, () async {
      await requestListing();
      await getCustomerProfile();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MLSView oldWidget) {
    if (widget.listing.sSearch!.isNotEmpty) {
      this.sSearch = widget.listing.sSearch!;
    }
    Future.delayed(Duration.zero, () async {
      await requestListing();
      await getCustomerProfile();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: headerColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: false,
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 2,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            resizeToAvoidBottomInset: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: Container(
              margin: EdgeInsets.only(top: 60),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: IconButton(
                  icon:
                      Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                  onPressed: () {
                    if (widget.routing == false) {
                      Navigator.pop(context);
                    } else {
                      widget.callbackRouting(this.widget.routing);
                    }
                  },
                ),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 0),
                      //Image Slider Gallery
                      Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: imageList.length == 0
                            ? Image.asset(
                                "assets/images/house-test.jpeg",
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                              )
                            : BannerCarousel(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                showIndicator: true,
                                banners: listBanners ?? [],
                                customizedIndicators: IndicatorModel.animation(
                                    width: 20,
                                    height: 5,
                                    spaceBetween: 3,
                                    widthAnimation: 50),
                                activeColor: buttonsColor,
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                spaceBetween: 2,
                                disableColor: Colors.white,
                                animation: true,
                                borderRadius: 10,
                                indicatorBottom: false,
                                onTap: (id) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarouselImageFullScreen(
                                      imageList: imageList,
                                      index: this.imageList.indexOf(id),
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      //Listing Details
                      Container(
                        //height: MediaQuery.of(context).size.height * 0.6,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Header Card
                              Container(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[700],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                getTypeOfSell(widget
                                                    .listing.sTypeOfSell!),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: colorListingStatus,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                widget.listing.sLystingStatus!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                      text: widget.listing!
                                                          .sPropertyAddress!),
                                                );
                                                Flushbar flush = Flushbar(
                                                  message:
                                                      'Address copied to clipboard',
                                                  flushbarStyle:
                                                      FlushbarStyle.FLOATING,
                                                  margin: EdgeInsets.all(8.0),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  icon: Icon(
                                                    Icons.info_outline,
                                                    size: 28.0,
                                                    color: Colors.white,
                                                  ),
                                                  duration:
                                                      Duration(seconds: 3),
                                                  leftBarIndicatorColor:
                                                      headerColor,
                                                );
                                                flush.show(context);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: Colors.grey[400]!,
                                                      width: 1),
                                                ),
                                                child: Icon(
                                                  Icons.copy,
                                                  color: headerColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  addressP1,
                                                  style: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.grey[800],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  addressP2,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await AnalitysService()
                                                .sendAnalyticsEvent(
                                              'shares_listing__click',
                                              {
                                                "screen_view":
                                                    "listing_view_screen",
                                                "item_id":
                                                    this.widget.listing.sSearch,
                                                'item_type': this
                                                    .widget
                                                    .listing
                                                    .sPropertyType
                                              },
                                            );
                                            await shareListing();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 12),
                                            child: Icon(
                                              Icons.share,
                                              color: Colors.grey[700],
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            if (!widget.listing.bIsFavorite!) {
                                              setState(() {
                                                widget.listing.bIsFavorite =
                                                    true;
                                              });
                                              this.widget.callback(true);
                                            } else {
                                              setState(() {
                                                widget.listing.bIsFavorite =
                                                    false;
                                              });
                                              this.widget.callback(false);
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 12),
                                            child:
                                                this.widget.listing.bIsFavorite!
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: headerColor,
                                                        size: 32,
                                                      )
                                                    : Icon(
                                                        FontAwesomeIcons.heart,
                                                        color: headerColor,
                                                        size: 32,
                                                      ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //Tags
                              // Add wrap clips
                              if (this.widget.listing.sTags != null)
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  width: MediaQuery.of(context).size.width *
                                      .95, // Set width to card width minus padding
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing:
                                        10, // Positive value to wrap tags to next line
                                    children: [
                                      for (var tag
                                          in this.widget.listing.sTags!)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          margin: EdgeInsets.only(right: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 14),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (this.widget.listing.sTags != null)
                                SizedBox(
                                  height: 10,
                                ),
                              //Price Card
                              Container(
                                height: 95,
                                width: MediaQuery.of(context).size.width * 0.94,
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "\$${formatter.format(this.widget.listing.nCurrentPrice)}",
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 26,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 2),
                                          child: Text(
                                            "\$${formatter.format(this.widget.listing.nPricePerSqft)}/sqft",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Listed ${this.widget.listing.nDaysOnZipcular != null ? this.widget.listing.nDaysOnZipcular : '---------------'} ",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              //Info Listing Card
                              Container(
                                height: 85,
                                width: MediaQuery.of(context).size.width * 0.94,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Beds",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.nBedrooms.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Baths",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.nBathrooms
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Half Baths",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.nHalfBaths
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sqft",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            formatter.format(
                                                this.widget.listing.nSqft),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Year Built",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.nYearBuilt
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              // Description Card
                              Container(
                                height: 85,
                                width: MediaQuery.of(context).size.width * 0.94,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Property Type",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.sPropertyType!,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lot Size",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            widget.listing.sLotSize.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hoa Fee",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            "\$${widget.listing.nMonthlyHoaFee.toString()}",
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              // Agent Card
                              Container(
                                height: 85,
                                width: MediaQuery.of(context).size.width * 0.94,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          "Agent:",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          widget.listing.sContactName!,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 90,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Caller Button
                      Container(
                        height: 50,
                        width: loadingCall == true
                            ? 80
                            : MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          color: headerColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              loadingCall = true;
                            });
                            await allowAction('phone_number');
                            setState(() {
                              loadingCall = false;
                            });
                          },
                          child: loadingCall == true
                              ? Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: headerColor,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 0,
                                    ),
                                    Text(
                                      "Call",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  ///
  ///
  /// Services Request and Utils
  ///
  getCustomerProfile() async {
    if (this.widget.listing.sInvitationCode!.isNotEmpty == true) {
      ResponseService response = await ListingFacade()
          .getCustomerProfile(this.widget.listing.sInvitationCode!);
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
          this.customer = response.data as CustomerModel;
        });
      }
    }
  }

  requestListing() async {
    setState(() {
      loading = true;
    });

    try {
      ResponseService result = await ListingFacade().getlysting(this.sSearch,
          this.widget.listing.sLogicStatus!, this.widget.isMyListing);

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
          this.widget.listing = result.data as Listing;
          getColorStatus(this.widget.listing.sLystingStatus!);
          principalAddress(this.widget.listing.sPropertyAddress!);

          if (this.widget.listing.sResourcesUrl == null) {
            this.widget.listing.sResourcesUrl = [];
          } else {
            for (var item in this.widget.listing.sResourcesUrl) {
              listBanners.add(new BannerModel(imagePath: item, id: item));
              this.imageList.add(item);
            }
          }
        });
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }

    setState(() {
      loading = false;
    });
  }

// Utils

  getColorStatus(String status) {
    colorListingStatus = baseColor;
    setState(() {
      switch (status) {
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
    });
  }

  shareListing() async {
    if (widget.listing.sSocialShareLink!.isEmpty) {
      final link = await createSocialShare(widget.listing);
      final response =
          await ListingFacade().savePreviewShare(widget.listing.sSearch!, link);
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
          widget.listing.sSocialShareLink = link;
        });
      }
    }
    Share.share(widget.listing.sSocialShareLink!, subject: 'Zeamless App.');
  }

  principalAddress(String address) {
    List<String> addressList = address.split(",");
    setState(() {
      addressP1 = addressList[0];
      addressP2 = addressList[1] +
          "," +
          addressList[2] +
          ' ' +
          widget.listing.sZipCode!;
    });
  }

  allowAction(String parameter) async {
    setState(() {
      loadingCall = parameter == 'phone_number';
    });

    try {
      ResponseService result =
          await ListingFacade().allowAction(this.sSearch, parameter);
      if (result.data != null) {
        if (parameter == 'phone_number') {
          if (result.data.isEmpty) {
            final flush = Flushbar(
              message: "Agent's phone number is not available.",
              flushbarStyle: FlushbarStyle.FLOATING,
              margin: EdgeInsets.all(8.0),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              icon: Icon(
                Icons.info_outline,
                size: 28.0,
                color: Theme.of(context).primaryColor,
              ),
              leftBarIndicatorColor: Theme.of(context).primaryColor,
            );
            flush.show(context);
          } else {
            await _makePhoneCall(result.data);
          }
        }
      } else {
        final flush = Flushbar(
          message: "Agent's phone number is not available.",
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: EdgeInsets.all(8.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          icon: Icon(
            Icons.info_outline,
            size: 28.0,
            color: Theme.of(context).primaryColor,
          ),
          leftBarIndicatorColor: Theme.of(context).primaryColor,
        );
        flush.show(context);
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }

    setState(() {
      loadingCall = false;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } else {
      final flush = Flushbar(
        message:
            "The number can not be provided by the system, please try again later",
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Theme.of(context).primaryColor,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Theme.of(context).primaryColor,
      );
      flush.show(context);
    }
  }
}
