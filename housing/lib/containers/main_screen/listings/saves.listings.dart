import 'package:another_flushbar/flushbar.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_preview.component.dart';
import 'package:zipcular/containers/main_screen/listings/panel/sliding_panel.widget.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/provider/favorites.provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class SavedHouses extends StatefulWidget {
  SavedHouses({Key? key}) : super(key: key);

  @override
  _SavedHousesState createState() => _SavedHousesState();
}

class _SavedHousesState extends State<SavedHouses>
    with TickerProviderStateMixin {
  bool loading = false;
  double _initFabHeight = 120.0;
  double fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;
  late final ScrollController scrollController;
  late final PanelController panelController;
  CustomerModel customer = CustomerModel.empty();
  late Listing listing = new Listing();
  List<Listing> favorites = [];

  @override
  void initState() {
    scrollController = ScrollController();
    panelController = PanelController();
    fabHeight = _initFabHeight;

    final chProvider = Provider.of<FavoriteProvider>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      if (chProvider.initialized == false) {
        await initComponent(chProvider);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        toolbarHeight: 45,
        leadingWidth: 0,
        title: Text(
          'Favorites',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, chatProvider, _) {
          favorites = chatProvider.favorites;
          return loading == true
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 2,
                    color: headerColor,
                  ),
                )
              : this.favorites.length > 0
                  ? SlidingUpPanel(
                      snapPoint: .4,
                      disableDraggableOnScrolling: false,
                      maxHeight: MediaQuery.of(context).size.height,
                      minHeight: 0,
                      parallaxEnabled: false,
                      parallaxOffset: .5,
                      body: getBody(chatProvider),
                      defaultPanelState: PanelState.CLOSED,
                      controller: panelController,
                      scrollController: scrollController,
                      panelBuilder: () {
                        return SlidingPanel(
                          showPanelAccess: true,
                          customer: customer,
                          listing: listing,
                          scrollController: scrollController,
                          panelController: panelController,
                          removeTop: false,
                        );
                      },
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0)),
                      onPanelSlide: (double pos) => setState(() {
                        fabHeight =
                            pos * (_panelHeightOpen - _panelHeightClosed) +
                                _initFabHeight;
                      }),
                      backdropOpacity: 0.7,
                      backdropEnabled: true,
                      backdropTapClosesPanel: true,
                      isDraggable: true,
                      margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                    )
                  : Center(
                      child: EmptyWidget(
                        hideBackgroundAnimation: false,
                        image: null,
                        packageImage: PackageImage.Image_3,
                        title: 'No Listings Saved',
                        subTitle: 'Please select your favorites',
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
                    );
        },
      ),
    );
  }

  Widget getBody(FavoriteProvider chatProvider) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 175),
      child: Stack(
        children: [
          ListingPreview(
            appyScroll: false,
            showProfile: true,
            isEditMode: false,
            isPreviewFavorite: true,
            itemsData: this.favorites.cast<Listing>(),
            onCallback: (val) async {
              if (val.item2 == false) {
                chatProvider.deleteFavorite(val.item1);
                Flushbar(
                  message: 'Lisitng removed from favorites',
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
              }
            },
            callbackRemoveListing: (val) {},
            callbackOpenProfile: (response) async {
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
          ),
        ],
      ),
    );
  }

  initComponent(FavoriteProvider chProvider) async {
    setState(() {
      loading = true;
    });
    await chProvider.fetchFavoriteFromDatabase();
    setState(() {
      loading = false;
    });
  }
}
