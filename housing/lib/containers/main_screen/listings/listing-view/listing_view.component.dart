import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:banner_carousel/banner_carousel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/chat/message_screen.component.dart';
import 'package:zipcular/containers/components/customer_profile/customer_profile.component.dart';
import 'package:zipcular/containers/widgets/common/carousel_image_full_screen.widget.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/models/chat/chat_validation.model.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/chat.facade.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../../models/listing/search/listing.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingView extends StatefulWidget {
  Listing listing;
  bool isMyListing;
  bool routing;
  ValueChanged<bool> callback;
  ValueChanged<bool> callbackRouting;
  String invitationCode = "";

  ListingView(
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
  State<ListingView> createState() => _ListingViewState();
}

class _ListingViewState extends State<ListingView>
    with TickerProviderStateMixin {
  late TabController? _tabController;
  CustomerModel customer = CustomerModel.empty();
  List<BannerModel> listBanners = List.empty(growable: true);
  bool loading = false;
  bool loadingCall = false;
  bool loadingChat = false;
  bool loadingEmail = false;
  List<String> imageList = List.empty(growable: true);
  List<String> amenitiesList = List.empty(growable: true);
  var formatter = new NumberFormat("#,###,###", "en_US");
  String sSearch = "";
  BuildContext? dialogContext;
  final emailController = TextEditingController();
  UserRepository userRepository = new UserRepository();
  Color colorListingStatus = Colors.black;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    initTextField();
    this.sSearch = widget.listing.sSearch!;
    Future.delayed(Duration.zero, () async {
      await requestListing();
      await getCustomerProfile();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ListingView oldWidget) {
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
    _tabController!.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final conversations = chatProvider.conversations;
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.startTop,
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
                      icon: Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 16),
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
                                    customizedIndicators:
                                        IndicatorModel.animation(
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
                                  SizedBox(
                                    height: 10,
                                  ),
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
                                            Text(
                                              widget.listing.sPropertyType!,
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  (widget.listing.bKeepAddressPrivate !=
                                                              null
                                                          ? widget.listing
                                                              .bKeepAddressPrivate!
                                                          : false)
                                                      ? Icons.location_off
                                                      : Icons.location_on,
                                                  color: Colors.grey[600],
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  widget.listing
                                                              .sPropertyAddress !=
                                                          null
                                                      ? widget.listing
                                                          .sPropertyAddress!
                                                      : '',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  this
                                                      .widget
                                                      .listing
                                                      .sLystingStatus!,
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      color: getColorStatus(this
                                                          .widget
                                                          .listing
                                                          .sLystingStatus!),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  getTypeOfSell(widget
                                                      .listing.sTypeOfSell!),
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      color: Colors.grey[700]),
                                                )
                                              ],
                                            )
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
                                                    "item_id": this
                                                        .widget
                                                        .listing
                                                        .sSearch,
                                                    'item_type': this
                                                        .widget
                                                        .listing
                                                        .sPropertyType
                                                  },
                                                );
                                                await shareListing();
                                              },
                                              child: Icon(
                                                Icons.share,
                                                color: Colors.grey[700],
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Container(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (!widget
                                                      .listing.bIsFavorite!) {
                                                    setState(() {
                                                      widget.listing
                                                          .bIsFavorite = true;
                                                    });
                                                    this.widget.callback(true);
                                                  } else {
                                                    setState(() {
                                                      widget.listing
                                                          .bIsFavorite = false;
                                                    });
                                                    this.widget.callback(false);
                                                  }
                                                },
                                                child: this
                                                        .widget
                                                        .listing
                                                        .bIsFavorite!
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

                                  //Price Card
                                  Container(
                                    height: 95,
                                    width: MediaQuery.of(context).size.width *
                                        0.94,
                                    padding: EdgeInsets.all(16),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
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
                                  Visibility(
                                    visible: widget.listing.sPropertyType ==
                                                "Single Family" ||
                                            widget.listing.sPropertyType ==
                                                "Apartment" ||
                                            widget.listing.sPropertyType ==
                                                "Condo" ||
                                            widget.listing.sPropertyType ==
                                                "Townhome"
                                        ? true
                                        : false,
                                    child: Container(
                                      height: 85,
                                      width: MediaQuery.of(context).size.width *
                                          0.94,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      alignment: Alignment.center,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 12),
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
                                                  widget.listing.nBedrooms
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
                                                  formatter.format(this
                                                      .widget
                                                      .listing
                                                      .nSqft),
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
                                  ),
                                  Visibility(
                                    visible: widget.listing.sTitle!.isNotEmpty,
                                    child: SizedBox(
                                      height: 10,
                                    ),
                                  ),
                                  //Sales Pitch Card
                                  Visibility(
                                    visible: widget.listing.sTitle!.isNotEmpty,
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width *
                                          0.94,
                                      padding: EdgeInsets.all(16),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.listing.sTitle!.isNotEmpty
                                                  ? widget.listing.sTitle!
                                                  : "Not Provided",
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  //Numbers Card - Use propper properties
                                  Container(
                                    height: 110,
                                    width: MediaQuery.of(context).size.width *
                                        0.94,
                                    padding: EdgeInsets.all(16),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
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
                                              "Est After Repair Value",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              this.widget.listing.nEstARV !=
                                                      null
                                                  ? "\$${formatter.format(this.widget.listing.nEstARV)}"
                                                  : 'Not provided',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              this
                                                          .widget
                                                          .listing
                                                          .nPricePerSqftARV !=
                                                      null
                                                  ? "\$${formatter.format(this.widget.listing.nPricePerSqftARV)}/sqft"
                                                  : "N/A",
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Estimated Spread",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              this.widget.listing.nEstSpread !=
                                                      null
                                                  ? "\$${formatter.format(this.widget.listing.nEstSpread)}"
                                                  : 'N/A',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  //Info Tabs Card
                                  Container(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width *
                                        0.94,
                                    padding: EdgeInsets.all(0),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          color: headerColor,
                                          child: TabBar(
                                            indicatorColor: Colors.grey[100],
                                            labelPadding: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            controller: _tabController,
                                            labelColor: Colors.white,
                                            unselectedLabelColor:
                                                Colors.grey[100],
                                            isScrollable: true,
                                            automaticIndicatorColorAdjustment:
                                                true,
                                            overlayColor: MaterialStateProperty
                                                .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                              if (states.contains(
                                                  MaterialState.pressed))
                                                return Colors.grey[100];
                                            }),
                                            indicatorSize:
                                                TabBarIndicatorSize.label,
                                            tabs: [
                                              Tab(text: "INFORMATION"),
                                              Tab(text: "TERMS"),
                                              Tab(text: "AMENITIES"),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 20, top: 20),
                                            height: 350,
                                            width: double.maxFinite,
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                loadInformation(),
                                                loadTerms(),
                                                loadAmenities()
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  //Comparables Card
                                  Visibility(
                                    visible: this
                                        .widget
                                        .listing
                                        .sCompsInfo
                                        .isNotEmpty,
                                    child: Container(
                                      height: calculateCompsSize(),
                                      width: MediaQuery.of(context).size.width *
                                          0.94,
                                      padding: EdgeInsets.all(16),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Comparables Sales",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .2,
                                                      child: Text('Price'),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .45,
                                                      child: Text('Address'),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .2,
                                                      child: Text('Link'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Column(
                                              children: [
                                                for (var comp in widget
                                                    .listing.sCompsInfo)
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 2),
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0,
                                                                    right: 10),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .2,
                                                            child: Text(
                                                              comp.nCompPrice !=
                                                                      null
                                                                  ? "${comp.nCompPrice}"
                                                                  : 'Not Provided',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[800],
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 15,
                                                                    right: 10),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .45,
                                                            child: Text(
                                                                comp.sCompAddress !=
                                                                        null
                                                                    ? splitAddress(comp
                                                                        .sCompAddress)
                                                                    : 'Not Provided',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 12,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 0,
                                                                    right: 10),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .2,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                if (!comp
                                                                    .sCompLink
                                                                    .toString()
                                                                    .contains(
                                                                        'https://')) {
                                                                  comp.sCompLink =
                                                                      'https://' +
                                                                          comp.sCompLink;
                                                                }
                                                                final Uri _url =
                                                                    Uri.parse(comp
                                                                        .sCompLink);
                                                                if (await canLaunchUrl(
                                                                    _url)) {
                                                                  await launchUrl(
                                                                      _url);
                                                                } else {
                                                                  final flush =
                                                                      Flushbar(
                                                                    message:
                                                                        "Not valid Link.",
                                                                    flushbarStyle:
                                                                        FlushbarStyle
                                                                            .FLOATING,
                                                                    margin: EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0)),
                                                                    icon: Icon(
                                                                      Icons
                                                                          .info_outline,
                                                                      size:
                                                                          28.0,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                    ),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                    leftBarIndicatorColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                  );
                                                                  flush.show(
                                                                      context);
                                                                }
                                                              },
                                                              child: Text(
                                                                splitUrl(comp
                                                                    .sCompLink),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color:
                                                                      headerColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),

                                  //Showing Card
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width *
                                        0.94,
                                    padding: EdgeInsets.all(16),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 20,
                                          color: Colors.grey[600],
                                        )),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Showing Date: ",
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          widget.listing.sShowingDateTime!
                                                  .isEmpty
                                              ? "Not Provided"
                                              : widget
                                                  .listing.sShowingDateTime!,
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  //Contact Card
                                  Container(
                                    height: 140,
                                    width: MediaQuery.of(context).size.width *
                                        0.94,
                                    padding: EdgeInsets.all(16),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerProfile(
                                                  customer: this.customer,
                                                  routing: false,
                                                  callback: (value) {},
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withOpacity(0.6),
                                                  Colors.white.withOpacity(0.9),
                                                ],
                                              ),
                                            ),
                                            height: 120,
                                            width: 120,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              radius: 70,
                                              child: ClipOval(
                                                child: this
                                                        .customer
                                                        .sProfilePicture!
                                                        .isEmpty
                                                    ? Image.asset(
                                                        'assets/images/friend1.jpg',
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        this
                                                            .customer
                                                            .sProfilePicture!,
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15.0,
                                        ),
                                        Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.listing.sContactName!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 24.0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                customer.nProperties!
                                                        .toString() +
                                                    " Listings",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CustomerProfile(
                                                        customer: this.customer,
                                                        routing: false,
                                                        callback: (value) {},
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 28,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: headerColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Listings",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 14.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 170,
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // CHAT SELLER

                          Visibility(
                            visible: widget.listing.sInvitationCode !=
                                widget.invitationCode,
                            child: InkWell(
                              onTap: () async {
                                // Init ChatUSer
                                ChatUser chat =
                                    getChatInformation(conversations);
                                // If chat exist, go to chat
                                ChatValidation? validateChat =
                                    await validateAccess(
                                        widget.listing.sInvitationCode!,
                                        this.sSearch,
                                        'chat',
                                        'listing');
                                if (validateChat!.bContinue == true) {
                                  setState(() {
                                    loadingChat = false;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessagesScreen(
                                        chat: chat,
                                        callback: (value) {},
                                      ),
                                    ),
                                  ).then((value) async => {
                                        await chatProvider
                                            .fetchConversationsFromDatabase()
                                      });
                                } else {
                                  final flush = Flushbar(
                                    message: validateChat.sDescription,
                                    flushbarStyle: FlushbarStyle.FLOATING,
                                    margin: EdgeInsets.all(8.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 28.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    duration: Duration(seconds: 2),
                                    leftBarIndicatorColor:
                                        Theme.of(context).primaryColor,
                                  );
                                  flush.show(context);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 30),
                                width: MediaQuery.of(context).size.width * 0.30,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: headerColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color.fromRGBO(169, 176, 185, 0.42),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: loadingChat == true
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Icon(
                                            //   Icons.phone,
                                            //   color: headerColor,
                                            // ),
                                            // SizedBox(
                                            //   width: 8,
                                            // ),
                                            loadingChat == true
                                                ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Row(children: [
                                                    Icon(
                                                      Icons.chat,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      'Chat',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                  ]),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // EMAIL SELLER
                          Visibility(
                            visible: widget.listing.sInvitationCode !=
                                widget.invitationCode,
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  loadingEmail = true;
                                });
                                ChatValidation validateChat =
                                    await validateAccess(
                                        widget.listing.sInvitationCode!,
                                        this.sSearch,
                                        'email',
                                        'listing');
                                if (validateChat.bContinue == true) {
                                  setState(() {
                                    loadingEmail = false;
                                  });
                                  final flush = Flushbar(
                                    message: validateChat.sHeader! +
                                        ": " +
                                        validateChat.sDescription!,
                                    flushbarStyle: FlushbarStyle.GROUNDED,
                                    margin: EdgeInsets.all(8.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 28.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    duration: Duration(seconds: 8),
                                    leftBarIndicatorColor:
                                        Theme.of(context).primaryColor,
                                  );
                                  flush.show(context);
                                  dialogWithBodyToSendEmail();
                                } else {
                                  setState(() {
                                    loadingEmail = false;
                                  });
                                  final flush = Flushbar(
                                    message: validateChat.sDescription,
                                    flushbarStyle: FlushbarStyle.FLOATING,
                                    margin: EdgeInsets.all(8.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 28.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    duration: Duration(seconds: 2),
                                    leftBarIndicatorColor:
                                        Theme.of(context).primaryColor,
                                  );
                                  flush.show(context);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 30),
                                width: MediaQuery.of(context).size.width * 0.33,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: headerColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color.fromRGBO(169, 176, 185, 0.42),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: loadingEmail == true
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mark_email_read,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // PHONE CALL
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  loadAmenities() {
    return amenitiesList.length > 0
        ? Wrap(
            spacing: 10,
            children: [
              for (String item in amenitiesList)
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                )
            ],
          )
        : Text('Not provided',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]));
  }

  loadInformation() {
    Widget result = Container();
    try {
      if (widget.listing.sPropertyType == "Multi-Unit Complex") {
        result = SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DataTable(
              checkboxHorizontalMargin: 0,
              headingRowHeight: 0,
              dividerThickness: 0,
              horizontalMargin: 0,
              columnSpacing: 18,
              dataRowHeight: 65,
              border: TableBorder.all(color: Colors.white),
              showBottomBorder: false,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              columns: [
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Property Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sPropertyType!,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prop. Condition",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sPropertyCondition!,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Units",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.nNumberofUnits != null
                              ? this.widget.listing.nNumberofUnits.toString()
                              : "0",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lot Size",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sLotSize ?? "Not Provided",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cooling Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sCoolingType!.isNotEmpty
                              ? this.widget.listing.sCoolingType!
                              : "Not Provided",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Heating Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sHeatingType!.isNotEmpty
                              ? this.widget.listing.sHeatingType!
                              : "Not Provided",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ]),

          //Property Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Property Description",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                this.widget.listing.sPropertyDescription!.isEmpty
                    ? "No Description"
                    : decodeTextFromServer(
                        this.widget.listing.sPropertyDescription!),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
          SizedBox(
            height: 8,
          )
        ]));
      } else if (widget.listing.sPropertyType == "Lot") {
        result = SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //Property Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Property Type",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    this.widget.listing.sPropertyType!,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 14),
          //Lot Size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lot Size",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    this.widget.listing.sLotSize ?? "Not Provided",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          //Parking Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lot Legal Description",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    this.widget.listing.sLotLegalDescription!.isEmpty
                        ? "Not Provided"
                        : this.widget.listing.sLotLegalDescription!,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          //Property Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Property Description",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                this.widget.listing.sPropertyDescription!.isEmpty
                    ? "No Description"
                    : decodeTextFromServer(
                        this.widget.listing.sPropertyDescription!),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
          SizedBox(
            height: 14,
          )
        ]));
      } else if (widget.listing.sPropertyType == "Single Family" ||
          widget.listing.sPropertyType == "Apartment" ||
          widget.listing.sPropertyType == "Condo" ||
          widget.listing.sPropertyType == "Townhome") {
        result = SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DataTable(
              checkboxHorizontalMargin: 0,
              headingRowHeight: 0,
              dividerThickness: 0,
              horizontalMargin: 0,
              columnSpacing: 18,
              dataRowHeight: 65,
              border: TableBorder.all(color: Colors.white),
              showBottomBorder: false,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              columns: [
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Property Type",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        this.widget.listing.sPropertyType!,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Property Condition",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sPropertyCondition!,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vacancy",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sVacancyType!.isNotEmpty
                              ? this.widget.listing.sVacancyType!
                              : 'Not Provided',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lot Size",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sLotSize ?? "Not Provided",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cooling Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sCoolingType!.isNotEmpty
                              ? this.widget.listing.sCoolingType!
                              : 'Not Provided',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Heating Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sHeatingType!.isNotEmpty
                              ? this.widget.listing.sHeatingType!
                              : 'Not Provided',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parking Type",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.sParkingType!.isNotEmpty
                              ? this.widget.listing.sParkingType!
                              : 'Not Provided',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Covered Parking ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.nCoveredParking != null
                              ? this.widget.listing.nCoveredParking.toString()
                              : 'Not Provided',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "HOA Fee",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          this.widget.listing.nMonthlyHoaFee != null
                              ? "\$${this.widget.listing.nMonthlyHoaFee}"
                              : 'N/A',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ]),

          //Property Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Property Description",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                this.widget.listing.sPropertyDescription!.isNotEmpty
                    ? decodeTextFromServer(
                        this.widget.listing.sPropertyDescription!)
                    : 'No Description',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )
        ]));
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
    return result;
  }

  loadTerms() {
    Widget result = Container();
    try {
      result = SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //Property Type
        DataTable(
            checkboxHorizontalMargin: 0,
            headingRowHeight: 0,
            dividerThickness: 0,
            horizontalMargin: 0,
            border: TableBorder.all(color: Colors.white),
            showBottomBorder: false,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            columns: [
              DataColumn(
                  label: Text('',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Earnest Money Deposit",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      this.widget.listing.nEarnestMoney != null
                          ? "\$${formatter.format(this.widget.listing.nEarnestMoney)}"
                          : 'Not Provided',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EMD Terms",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      this.widget.listing.sEarnestMoneyTerms!.isNotEmpty
                          ? this.widget.listing.sEarnestMoneyTerms!
                          : 'Not Provided',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                )),
              ]),
            ]),
        SizedBox(height: 20),
        //Property Description
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Conditions and Disclaimers",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              this.widget.listing.sAdditionalDealTerms!.isNotEmpty
                  ? this.widget.listing.sAdditionalDealTerms!
                  : 'Not provided',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
        SizedBox(
          height: 8,
        )
      ]));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
    return result;
  }

  ///
  ///
  /// UTILS
  ///
  ///
  splitAddress(String address) {
    var addressArr = address.split(',');
    if (addressArr.length > 0) {
      address = addressArr[0] + '\n';
      for (var i = 1; i <= addressArr.length - 1; i++) {
        address = address + ',' + (addressArr[i]);
      }
      return address;
    } else {
      return address;
    }
  }

  splitUrl(String url) {
    var urlArr = url.split('.');
    if (urlArr.length > 0) {
      return urlArr[1];
    } else {
      return url;
    }
  }

  getColorStatus(String status) {
    Color colorListingStatus = baseColor;
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
    return colorListingStatus;
  }

  calculateCompsSize() {
    int result = 0;
    if (this.widget.listing.sCompsInfo != null) {
      if (this.widget.listing.sCompsInfo!.length > 0) {
        if (this.widget.listing.sCompsInfo!.length == 1) {
          result = 130;
        } else {
          result = this.widget.listing.sCompsInfo!.length * 85;
        }
      }
    }
    return result.toDouble();
  }

  String decodeTextFromServer(String text) {
    List<int> bytes = text.codeUnits;
    String decodedText = utf8.decode(bytes);
    return decodedText;
  }

  getChatInformation(List<ChatUser> conversations) {
    setState(() {
      loadingChat = true;
    });
    // Get element from chat provider
    late ChatUser? chat = null;
    if (conversations.length > 0) {
      if (conversations.any((element) => element.sLystingId == this.sSearch)) {
        chat = conversations
            .firstWhere((element) => element.sLystingId == this.sSearch);
      }
    }
    if (chat == null) {
      chat = new ChatUser(
          sLystingId: this.sSearch,
          bIsFavorite: false,
          bIsSender: true,
          sChatId: '',
          sChatMessageType: 'text',
          sLastMessageContent: '',
          sLastMessageCreatedTime: 0,
          sLystingName: widget.listing.sPropertyAddress,
          sLystingProfilePicture: widget.listing.sResourcesUrl!.length > 0
              ? widget.listing.sResourcesUrl![0]
              : '',
          sMessageCategory: 'listing',
          sMessageSubCategory: 'buying',
          sMessageStatus: "viewed",
          sUserInvitationCode: widget.listing.sInvitationCode,
          sUserProfilePicture: this.customer.sProfilePicture,
          bIsReported: false,
          bIsReportedByMe: false);
    }
    return chat;
  }

  dialogWithBodyToSendEmail() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Send Email',
            style: TextStyle(
                color: headerColor, fontSize: 20, fontWeight: FontWeight.bold),
          )),
          content: Container(
            margin: EdgeInsets.only(top: 10),
            width: double.maxFinite,
            height: MediaQuery.of(context).size.width * .75,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    maxLines: 12,
                    autocorrect: true,
                    decoration: InputDecoration(
                      labelText: 'Write your email here:',
                      hintText: 'Email body...',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        '"Spam equals instant ban"',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: buttonsColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: buttonsColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              onTap: () async {
                await sendEmail();
                initTextField();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: headerColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  "Send",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  initTextField() {
    String propertyAddress = this.widget.listing.sPropertyAddress != null
        ? this.widget.listing.sPropertyAddress!
        : "";
    setState(() {
      emailController.text = "Hi " +
          customer.sFirstName! +
          "!,\n \nI'm interested in your property located at " +
          propertyAddress +
          ".\n";
    });
  }

  ///
  ///
  /// Services Request
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
          if (this.widget.listing.sAmenities == null) {
            this.widget.listing.sAmenities = [];
          } else {
            for (var item in this.widget.listing.sAmenities!) {
              this.amenitiesList.add(item);
            }
          }
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

  sendEmail() async {
    bool sent = false;
    if (this.emailController.text.isNotEmpty == true) {
      ResponseService response = await FacadeChat().sendEmail(
          this.emailController.text,
          this.widget.invitationCode,
          this.sSearch,
          this.widget.listing.sContactEmail!);
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
        sent = true;
      }
    }
    return sent;
  }

  validateAccess(String sInvitationCode, String sLystingId, String sChannel,
      String sMessageCategory) async {
    ResponseService response = await ListingFacade().validateAccess(
        sInvitationCode, sLystingId, sChannel, sMessageCategory);

    if (response.bSuccess == true) {
      final result = response.data as ChatValidation;
      return result;
    } else {
      return null;
    }
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
}
