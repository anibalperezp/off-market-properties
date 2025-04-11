import 'dart:async';
import 'dart:math';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/common.localization.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/filter/filter.component.dart';
import 'package:zipcular/containers/main_screen/chat/chat_list.component.dart';
import 'package:zipcular/containers/main_screen/more/more.component.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/floating_search_bar.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/floating_search_bar_actions.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/floating_search_bar_transition.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/quick_filter/deals.widget.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/quick_filter/off_market.widget.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/quick_filter/tags.widget.dart';
import 'package:zipcular/containers/widgets/floating_search_bar/widgets/circular_button.dart';
import 'package:zipcular/models/filter/filter.model.dart';
import 'package:zipcular/models/listing/search/place.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';
import 'package:zipcular/repository/provider/network.provider.dart';
import 'package:zipcular/repository/provider/notifications.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'package:zipcular/repository/services/prod/common.service.dart';
import 'package:zipcular/repository/services/prod/search.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'main_screen/my_listings/my_listing.component.dart';
import 'main_screen/listings/list.listings.component.dart';
import 'main_screen/listings/saves.listings.dart';
import 'main_screen/map/map.component.dart';
import 'main_screen/notifications_tabs.component.dart';
import 'package:in_app_review/in_app_review.dart';

class HomePage extends StatefulWidget {
  double latitude;
  double longitude;
  double zoom;

  HomePage(
      {Key? key,
      double? latitude,
      double? longitude,
      double? zoom,
      SearchRequest? request})
      : latitude = latitude!,
        longitude = longitude!,
        zoom = zoom!,
        super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final controller = FloatingSearchBarController();
  UserRepository userRepository = new UserRepository();
  String queryModel = '';
  String sConcatenation = '';
  bool _isMap = false;
  bool enableLocation = true;
  bool isOnlyOffMarket = false;
  int _index = 0;
  Widget? widgetSaves;
  Widget? widgetSwitcher;
  BuildContext? dialogContext;
  SearchRequest? request;
  int get index => _index;
  late ChatProvider chatProviderG;
  CommonService commonService = new CommonService();
  late FilterModel? filterModel;
  InAppReview inAppReview = InAppReview.instance;

  @override
  initState() {
    // Init Provider
    this.chatProviderG = Provider.of<ChatProvider>(context, listen: false);
    widgetSaves = Container();
    Future.delayed(Duration.zero, () async {
      // Get data based on location
      await listingsByLocation(false);
      // Init WebSocket
      await this.chatProviderG.initWebSocketConnection();
      // Call Store Provider Services init
      await Provider.of<NotificationsProvider>(context, listen: false)
          .fetchNotificationsFromDatabase();
      Provider.of<ChatProvider>(context, listen: false)
          .fetchConversationsFromDatabase();
      await Provider.of<NetworkProvider>(context, listen: false)
          .fetchConnectionsFromDatabase();
      filterModel =
          Provider.of<FilterProvider>(context, listen: false).filterModel;
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    this.chatProviderG.closeWebSocketConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: buildSearchBar(context),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    final actions = [
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
      this.queryModel.length != 0
          ? FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                icon: Icon(Icons.clear, color: Colors.red, size: 29),
                onPressed: () {
                  Future.delayed(Duration.zero, () async {
                    setState(() {
                      this.sConcatenation = '';
                      this.queryModel = '';
                      this.request!.sConcatenation = '';
                    });
                    this.controller.clear();
                    this.controller.close();
                    await listingsByLocation(false);
                  });
                },
              ),
            )
          : Text(''),
      FloatingSearchBarAction.icon(
        icon: Consumer<NotificationsProvider>(
            builder: (context, notificationProvider, child) {
          return notificationProvider.notReadCounter > 0
              ? Container(
                  margin: EdgeInsets.only(right: 3),
                  child: badges.Badge(
                    badgeContent: Text(
                      notificationProvider.notReadCounter.toString(),
                      style: TextStyle(fontSize: 8, color: Colors.white),
                    ),
                    badgeStyle: badges.BadgeStyle(
                        badgeColor: headerColor,
                        shape: badges.BadgeShape.circle),
                    child: Image.asset(
                        "assets/images/icons/notifications_active.png",
                        height: 24,
                        width: 24),
                  ),
                )
              : Image.asset("assets/images/icons/notifications_active.png",
                  height: 24, width: 24);
        }),
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 400),
              child: NotificationsTab(),
            ),
          );
        },
      ),
      FloatingSearchBarAction.icon(
        icon:
            Image.asset("assets/images/icons/share.png", height: 24, width: 24),
        onTap: () async {
          String branchCode = await userRepository.readKey('branchCode');
          Share.share(
              branchCode.isNotEmpty
                  ? branchCode
                  : 'https://zeamless.app.link/4U1m2GePJBb',
              subject: 'Zeamless App.');
        },
      ),
    ];

    return Consumer<Search>(
      builder: (context, model, _) => FloatingSearchBar(
        automaticallyImplyBackButton: false,
        controller: controller,
        queryStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
        clearQueryOnClose: false,
        onQueryChanged: (query) async {
          if (query.length == 0 && this.queryModel.length > 0) {
            Future.delayed(Duration.zero, () {
              setState(() {
                this.sConcatenation = '';
                this.queryModel = '';
                this.request!.sConcatenation = '';
              });
              this.controller.clear();
              this.controller.close();
            });
          }
          await listingsByLocation(false);
          this.queryModel = query;
          model.onQueryChanged(query);
        },
        automaticallyImplyDrawerHamburger: true,
        leadingActions: [
          GestureDetector(
            onTap: () async {
              setState(() {
                this._isMap = this._isMap ? false : true;
                this.request!.isMap = _isMap;
              });
              await loadListingView(
                  this.widget.latitude, this.widget.longitude, this.request);
            },
            child: Container(
              height: 30,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: headerColor, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  this._isMap ? 'Map' : 'List',
                  style: TextStyle(color: headerColor, fontSize: 17),
                ),
              ),
            ),
          )
        ],
        elevation: 8,
        border: BorderSide(color: Colors.grey[300]!, width: 1),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
        hint: 'County, City, Zip, Address',
        iconColor: baseColor,
        transitionDuration: const Duration(milliseconds: 200),
        transitionCurve: Curves.easeInOutCubic,
        physics: const BouncingScrollPhysics(),
        axisAlignment: 0.0,
        openAxisAlignment: 0.0,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        actions: actions,
        progress: model.isLoading,
        debounceDelay: const Duration(milliseconds: 40),
        scrollPadding: EdgeInsets.zero,
        transition: CircularFloatingSearchBarTransition(),
        builder: (context, _) => buildExpandableBody(model),
        body: buildBody(),
        accentColor: baseColor,
        showVisibleFloatingFilter: true,
        callbackFilters: (value) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 900),
              child: Filter(),
            ),
          ).then((value) async {
            await listingsByFilter();
            setState(() {});
          }).catchError((error) {
            print("Error after filter applied.: $error");
          });
        },
        callbackDeal: (value) {
          floatingFilterDialog(context, 'Deals Filter', 'Description', 'deal');
          Provider.of<FilterProvider>(context, listen: false)
              .updateShowResults(false);
        },
        callbackOnlyOffMarket: (val) async {
          floatingFilterDialog(
              context, 'Off Market', 'Description', 'offMarket');
          Provider.of<FilterProvider>(context, listen: false)
              .updateShowResults(false);
        },
        callbackTags: (value) {
          floatingFilterDialog(context, 'Tags', 'Description', 'tags');
          Provider.of<FilterProvider>(context, listen: false)
              .updateShowResults(false);
        },
        callbackReturn: (value) {
          resetDialogAlert(context);
        },
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: min(index, 4),
            children: [
              widgetSwitcher == null
                  ? Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 80),
                            Text(
                              'Finding Listings ...',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 50),
                            CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(headerColor)),
                          ],
                        ),
                      ),
                    )
                  : this.widgetSwitcher!,
              this.widgetSaves!,
              MyListings(),
              ChatList(),
              More()
            ],
          ),
        ),
        buildBottomNavigationBar(),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (value) async {
        if (index == 1) {
          await AnalitysService()
              .setCurrentScreen('my_favorites_screen', 'SavesScreen');
        }
        setState(
          () {
            index = value;
            print('index: $index');
            if (index == 0) {
              widgetSwitcher = !this._isMap
                  ? MapApp(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      request: this.request!,
                      callback: (val) => setState(
                        () {
                          this.widget.latitude = val.target.latitude;
                          this.widget.longitude = val.target.longitude;
                          this.widget.zoom = val.zoom;
                          this.request!.nZoom = widget.zoom;
                        },
                      ),
                    )
                  : HousesList(request: this.request!);
            } else if (index == 1) {
              this.widgetSaves = SavedHouses();
            } else if (index == 2 || index == 3 || index == 4) {
              this.widgetSaves = Container();
              widgetSwitcher = Container();
            }
          },
        );
      },
      currentIndex: index,
      elevation: 5,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.grey[800],
      selectedFontSize: 14,
      unselectedItemColor: Colors.grey[600],
      selectedIconTheme: IconThemeData(size: 35, color: Colors.white),
      unselectedFontSize: 13,
      items: [
        BottomNavigationBarItem(
          icon: Container(
              padding: EdgeInsets.only(bottom: 6),
              child: Image.asset("assets/images/icons/search.png",
                  height: 30, width: 30)),
          label: 'Market', //Market
        ),
        BottomNavigationBarItem(
          icon: Container(
              padding: EdgeInsets.only(bottom: 6),
              child: Image.asset("assets/images/icons/favorite grey.png",
                  height: 30, width: 30)),
          label: 'Saves', //Saves
        ),
        BottomNavigationBarItem(
          icon: Container(
              padding: EdgeInsets.only(bottom: 6),
              child: Image.asset("assets/images/icons/home_pin.png",
                  height: 30, width: 30)),
          label: 'Dashboard', //My Listings
        ),
        BottomNavigationBarItem(
          icon: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return chatProvider.notReadCounter > 0
                  ? Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Badge(
                        label: Text(
                          chatProvider.notReadCounter.toString(),
                          style: TextStyle(fontSize: 9),
                        ),
                        child: Image.asset("assets/images/icons/chat.png",
                            height: 30, width: 30),
                        textColor: Colors.white,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Image.asset("assets/images/icons/chat.png",
                          height: 30, width: 30),
                    );
            },
          ),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return userProvider.user.nRequests > 0 ||
                      userProvider.user.bUpdateApp
                  ? Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Badge(
                        backgroundColor: headerColor,
                        offset: Offset(9, 0),
                        alignment: Alignment.topRight,
                        label: Text(
                          '*',
                          style: TextStyle(fontSize: 15),
                        ),
                        child: Image.asset("assets/images/icons/account.png",
                            height: 30, width: 30),
                        textColor: Colors.white,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Image.asset("assets/images/icons/account.png",
                          height: 30, width: 30),
                    );
            },
          ),
          label: 'More',
        ),
      ],
    );
  }

  Widget buildExpandableBody(Search model) {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: ImplicitlyAnimatedList<Place>(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        items: model.suggestions.take(6).toList(),
        areItemsTheSame: (a, b) => a == b,
        itemBuilder: (context, animation, place, i) {
          return SizeFadeTransition(
            animation: animation,
            child: buildItem(context, place),
          );
        },
        updateItemBuilder: (context, animation, place) {
          return FadeTransition(
            opacity: animation,
            child: buildItem(context, place),
          );
        },
      ),
    );
  }

  Widget buildItem(BuildContext context, Place place) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final model = Provider.of<Search>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            FloatingSearchBar.of(context)!.close();
            Future.delayed(
              const Duration(milliseconds: 500),
              () => model.clear(),
            );
            setState(() {
              this.sConcatenation = place.sConcatenationContent!;
              this.controller.query = place.sCustomerView!;
              this.queryModel = controller.query;
              this.widget.latitude = place.latitude!;
              this.widget.longitude = place.longitude!;
              this.widget.zoom = place.nZoomLevel!;
              this.request = new SearchRequest(
                isMap: place.sSearchType == 'Address' ? false : this._isMap,
                sConcatenation: this.sConcatenation,
                bIsDescendingOrder: true,
                nRangeFirstNumber: 0,
                nRangeLastNumber: 100,
                nZoom: widget.zoom,
                sSortAttribute: 'nFollowers',
              );
            });
            await loadListingView(
                this.widget.latitude, this.widget.longitude, this.request);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: model.suggestions == history
                        ? const Icon(Icons.history, key: Key('history'))
                        : const Icon(Icons.place, key: Key('place')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.sCustomerView!,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.level2Address,
                        style: textTheme.bodyMedium!
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (model.suggestions.isNotEmpty && place != model.suggestions.last)
          const Divider(height: 0),
      ],
    );
  }

  listingsByLocation(bool isLocal) async {
    this.enableLocation = await isEnableLocation();
    var locationData;
    if (this.enableLocation) {
      locationData = await getCurrentLocation();
    }

    if (locationData != null && isLocal) {
      this.widget.latitude = locationData.latitude;
      this.widget.longitude = locationData.longitude;
    }
    setState(() {
      this.request = new SearchRequest(
          isMap: this._isMap,
          sConcatenation: this.sConcatenation,
          bIsDescendingOrder: true,
          nRangeFirstNumber: 0,
          nRangeLastNumber: 100,
          nZoom: widget.zoom,
          sSortAttribute: 'nFollowers');
    });
    await loadListingView(
        this.widget.latitude, this.widget.longitude, this.request);
  }

  listingsByFilter() async {
    setState(() {
      this.request = new SearchRequest(
          isMap: this._isMap,
          sConcatenation: this.sConcatenation,
          bIsDescendingOrder: true,
          nRangeFirstNumber: 0,
          nRangeLastNumber: 100,
          nZoom: widget.zoom,
          sSortAttribute: 'nFollowers');
    });
    await loadListingView(
        this.widget.latitude, this.widget.longitude, this.request);
  }

  set index(int value) {
    _index = min(value, 4);
    _index >= 1 ? controller.hide() : controller.show();
    if (_index == 0) {
      loadListingView(
          this.widget.latitude, this.widget.longitude, this.request);
    }
    setState(() {});
  }

  loadListingView(latitude, longitude, request) async {
    Widget tempW = Container();
    try {
      if (!this._isMap) {
        tempW = MapApp(
            latitude: latitude,
            longitude: longitude,
            request: request,
            callback: (val) {
              setState(() {
                this.widget.latitude = val.target.latitude;
                this.widget.longitude = val.target.longitude;
                this.widget.zoom = val.zoom;
                this.request!.nZoom = widget.zoom;
              });
            });
      } else {
        tempW = HousesList(request: this.request!);
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() {
      this.widgetSwitcher = tempW;
    });
  }

  floatingFilterDialog(
      BuildContext context, String title, String content, String type) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      elevation: 10,
      builder: (BuildContext context) {
        return Consumer<FilterProvider>(
          builder: (context, filterProvider, child) {
            return Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
              height: 550,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    height: 40,
                    top: 20,
                    width: MediaQuery.of(context).size.width * .95,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[700]!,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    height: 350,
                    width: MediaQuery.of(context).size.width * .95,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (type == 'deal')
                            DealsWidget(
                              filterProvider: filterProvider,
                              callback: (list) {
                                setState(() {
                                  filterModel!.sTypeOfSell = list;
                                });
                                // update filter
                              },
                            ),
                          if (type == 'offMarket')
                            OffMarketWidget(
                              filterProvider: filterProvider,
                              callback: (list) {
                                setState(() {
                                  filterModel!.sLystingCategory = list;
                                });
                                // update filter
                              },
                            ),
                          if (type == 'tags')
                            TagsWidget(
                              filterProvider: filterProvider,
                              callback: (list) {
                                setState(() {
                                  filterModel!.sTags = list;
                                });
                                // update filter
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    child: filterProvider.showResults
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  filterProvider.updateLoading(true);
                                  await filterProvider
                                      .applyFilter(filterModel!);
                                  await listingsByLocation(false);
                                  await _requestReview();
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: headerColor,
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.grey[300]!,
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
                                    child: filterProvider.isLoading == true
                                        ? Container(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Apply',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  filterProvider.updateShowResults(false);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: headerColor,
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.grey[300]!,
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
                                    child: Text(
                                      filterProvider.isLoading
                                          ? 'Results: --'
                                          : filterProvider.result!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : InkWell(
                            onTap: () async {
                              filterProvider.updateLoading(true);
                              await filterProvider.applyFilter(filterModel!);
                              await listingsByLocation(false);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .95,
                              height: 55,
                              decoration: BoxDecoration(
                                color: headerColor,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey[300]!,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(169, 176, 185, 0.42),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: filterProvider.isLoading == true
                                    ? Container(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Apply',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                    bottom: 0,
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) async {
      await listingsByLocation(false);
    });
  }

  resetDialogAlert(BuildContext context) {
    Widget cancelButton = Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return TextButton(
          child: Text("Confirm",
              style: TextStyle(
                  color: headerColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          onPressed: () async {
            filterProvider.resetFilter();
            Navigator.pop(dialogContext!);
          },
        );
      },
    );
    Widget continueButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(dialogContext!);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Rest Filter'),
      content: Text('Are you sure you want to reset filter?'),
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

  Future<void> _requestReview() async {
    if (Provider.of<UserProvider>(context, listen: false).user.bReviewed ==
        false) {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
        await Provider.of<UserProvider>(context, listen: false).saveReview();
      }
    }
  }
}
