import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_preview.component.dart';
import 'package:zipcular/containers/main_screen/listings/panel/sliding_panel.widget.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/provider/favorites.provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class HousesList extends StatefulWidget {
  SearchRequest request;
  HousesList({Key? key, SearchRequest? request})
      : request = request!,
        super(key: key);

  @override
  _HousesListState createState() => _HousesListState();
}

class _HousesListState extends State<HousesList> {
  String? _selected;
  String? title;
  bool loading = false;
  Map<String, String>? values;
  dynamic listings;
  // Sliding Up Panel
  double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;
  late final ScrollController scrollController;
  late final PanelController panelController;
  CustomerModel customer = CustomerModel.empty();
  late Listing? listing = new Listing();

  @override
  void initState() {
    _selected = 'nFollowersDesc';
    title = 'Connections Hight to Low';
    values = {
      // Fix date format for sorting
      "Connections Hight to Low": 'nFollowersDesc',
      "Connections Low to High": 'nFollowersAsc',
      "Newest": 'sLystingDateDesc',
      "Oldest": 'sLystingDateAsc',
      "Price Low to High": 'nCurrentPriceAsc',
      "Price High to Low": 'nCurrentPriceDesc',
      "Price/sqft Low to High": 'nPricePerSqftAsc',
      "Price/sqft High to Low": 'nPricePerSqftDesc',
      "Home Age Low to High": 'nYearBuiltAsc',
      "Home Age Hight to Low": 'nYearBuiltDesc',
    };
    scrollController = ScrollController();
    panelController = PanelController();
    _fabHeight = _initFabHeight;
    Future.delayed(Duration.zero, () async {
      await requestListings();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HousesList oldWidget) {
    Future.delayed(Duration.zero, () async {
      print('Updated list View');
      await requestListings();
    });
    super.didUpdateWidget(oldWidget);
  }

  requestListings() async {
    setState(() {
      loading = true;
    });

    UserRepository userRepository = UserRepository();
    final sEastLng = await userRepository.readKey('sEastLng');
    final sNorthLat = await userRepository.readKey('sNorthLat');
    final sWestLng = await userRepository.readKey('sWestLng');
    final sSouthLat = await userRepository.readKey('sSouthLat');
    final nZoom = await userRepository.readKey('nZoom');

    setState(() {
      this.widget.request.sEastLng = double.tryParse(sEastLng)!;
      this.widget.request.sNorthLat = double.tryParse(sNorthLat)!;
      this.widget.request.sWestLng = double.tryParse(sWestLng)!;
      this.widget.request.sSouthLat = double.tryParse(sSouthLat)!;
      this.widget.request.nZoom = double.tryParse(nZoom)!;
    });

    try {
      ResponseService result =
          await ListingFacade().getlystings(this.widget.request);
      listings = [];

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
      } else {
        listings = result.data.list;
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 0),
      color: Colors.white,
      child: loading == true
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: headerColor,
              ),
            )
          : listings?.length == 0
              ? Center(
                  child: EmptyWidget(
                    image: null,
                    hideBackgroundAnimation: true,
                    packageImage: PackageImage.Image_3,
                    title: 'No Listings Available',
                    subTitle: 'Please Search Diferent Location',
                    titleTextStyle: TextStyle(
                      fontSize: 24,
                      color: Color(0xff9da9c7),
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xffabb8d6),
                    ),
                  ),
                )
              : SlidingUpPanel(
                  snapPoint: .72,
                  disableDraggableOnScrolling: false,
                  maxHeight: Platform.isAndroid
                      ? MediaQuery.of(context).size.height * .78
                      : MediaQuery.of(context).size.height * .80,
                  minHeight: 0,
                  parallaxEnabled: false,
                  parallaxOffset: .5,
                  body: getBody(),
                  defaultPanelState: PanelState.CLOSED,
                  controller: panelController,
                  scrollController: scrollController,
                  panelBuilder: () {
                    return SlidingPanel(
                      showPanelAccess: false,
                      customer: customer,
                      scrollController: scrollController,
                      panelController: panelController,
                      listing: listing!,
                      removeTop: true,
                    );
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  onPanelSlide: (double pos) => setState(() {
                    _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                        _initFabHeight;
                  }),
                  backdropOpacity: 0.7,
                  backdropEnabled: true,
                  backdropTapClosesPanel: true,
                  isDraggable: true,
                  margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                ),
    );
  }

  getBody() {
    return Consumer<FavoriteProvider>(
      builder: (context, chatProvider, _) {
        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 95, bottom: 120),
              child: ListingPreview(
                appyScroll: false,
                callbackOpenProfile: (response) async {
                  //Call sliding_up_panel2
                  if (response != null) {
                    setState(() {
                      customer = response.item1;
                      listing = response.item2;
                    });
                    this.panelController.animatePanelToSnapPoint(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  }
                },
                showProfile: true,
                isPreviewFavorite: true,
                isEditMode: false,
                itemsData: listings != null
                    ? listings.cast<Listing>()
                    : List.empty(growable: true),
                onCallback: (val) async {
                  String result = val.item2 == true
                      ? 'added to favorites'
                      : 'removed from favorites';
                  if (val.item2 == true) {
                    chatProvider.addFavorite(val.item1);
                  } else {
                    chatProvider.deleteFavorite(val.item1);
                  }
                  Flushbar(
                    message: 'Lisitng ' + result,
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
                  )..show(context);
                },
                callbackRemoveListing: (val) async {
                  await requestListings();
                },
              ),
            ),
            Container(
              color: Colors.white,
              height: Platform.isAndroid == true ? 45 : 80,
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                bottom: Platform.isAndroid == true ? 70 : 85,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 11),
                    child: Text(
                      'Sort By: ',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 11),
                    child: GestureDetector(
                      onTap: () async {
                        await AnalitysService()
                            .sendAnalyticsEvent('sort_open_click', {
                          "screen_view": "listings_screen",
                          "item_id": 'empty',
                          'item_type': 'dropdown_component'
                        });
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView(
                              children: values!.keys.map(
                                (String? key) {
                                  return RadioListTile<String?>(
                                    selected: true,
                                    selectedTileColor: Colors.white,
                                    activeColor: headerColor,
                                    title: Text(
                                      key!,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey[700]),
                                    ),
                                    value: values![key],
                                    groupValue: _selected!,
                                    onChanged: (String? value) async {
                                      setState(
                                        () {
                                          this._selected = value!;
                                          this.title = key;
                                        },
                                      );
                                      switch (_selected!) {
                                        case 'sLystingDateDesc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_oldest_click', {
                                            "screen_view": "listings_screen",
                                            "item_id": 'sort',
                                            'item_type': 'dropdown_component'
                                          });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = true;
                                            this.widget.request.sSortAttribute =
                                                'nSortDate';
                                          });

                                          break;
                                        case 'sLystingDateAsc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_newest_click', {
                                            "screen_view": "listings_screen",
                                            "item_id": 'sort',
                                            'item_type': 'dropdown_component'
                                          });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = false;
                                            this.widget.request.sSortAttribute =
                                                'nSortDate';
                                          });

                                        case 'nFollowersDesc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_followers_desc_click', {
                                            "screen_view": "listings_screen",
                                            "item_id": 'sort',
                                            'item_type': 'dropdown_component'
                                          });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = true;
                                            this.widget.request.sSortAttribute =
                                                'nFollowers';
                                          });

                                          break;
                                        case 'nFollowersAsc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_followers_asc_click', {
                                            "screen_view": "listings_screen",
                                            "item_id": 'sort',
                                            'item_type': 'dropdown_component'
                                          });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = false;
                                            this.widget.request.sSortAttribute =
                                                'nFollowers';
                                          });

                                          break;
                                        case 'nCurrentPriceDesc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_price_low_to_hight_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = true;
                                            this.widget.request.sSortAttribute =
                                                'nCurrentPrice';
                                          });

                                          break;
                                        case 'nCurrentPriceAsc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_price_high_to_low_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = false;
                                            this.widget.request.sSortAttribute =
                                                'nCurrentPrice';
                                          });

                                          break;
                                        case 'nPricePerSqftDesc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_price_sqft_low_to_high_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = true;
                                            this.widget.request.sSortAttribute =
                                                'nPricePerSqft';
                                          });

                                          break;
                                        case 'nPricePerSqftAsc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_price_sqft_high_to_low_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = false;
                                            this.widget.request.sSortAttribute =
                                                'nPricePerSqft';
                                          });

                                          break;
                                        case 'nYearBuiltDesc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_year_built_low_to_high_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = true;
                                            this.widget.request.sSortAttribute =
                                                'nYearBuilt';
                                          });

                                          break;
                                        case 'nYearBuiltAsc':
                                          await AnalitysService()
                                              .sendAnalyticsEvent(
                                                  'sort_year_built_high_to_low_click',
                                                  {
                                                "screen_view":
                                                    "listings_screen",
                                                "item_id": 'sort',
                                                'item_type':
                                                    'dropdown_component'
                                              });
                                          setState(() {
                                            this
                                                .widget
                                                .request
                                                .bIsDescendingOrder = false;
                                            this.widget.request.sSortAttribute =
                                                'nYearBuilt';
                                          });
                                          break;
                                      }

                                      Navigator.pop(context);
                                      await requestListings();
                                    },
                                  );
                                },
                              ).toList(),
                            );
                          },
                        );
                      },
                      child: Text(
                        title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: headerColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 15)
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
