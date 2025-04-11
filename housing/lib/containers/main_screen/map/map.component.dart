import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:zipcular/commons/adds-helper.component.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/common.localization.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_map_preview.component.dart';
import 'package:zipcular/containers/main_screen/listings/panel/sliding_panel.widget.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/creation_wizard_house.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'package:zipcular/models/map/place.dart';
import 'package:zipcular/models/map/pin_info.dart';
import 'package:intl/intl.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../models/listing/search/listing.dart';

class MapApp extends StatefulWidget {
  double latitude;
  double longitude;
  SearchRequest request;
  ValueChanged<google.CameraPosition> callback;

  MapApp(
      {Key? key,
      double? latitude,
      double? longitude,
      SearchRequest? request,
      ValueChanged<google.CameraPosition>? callback})
      : latitude = latitude!,
        longitude = longitude!,
        request = request!,
        callback = callback!,
        super(key: key);

  @override
  MapState createState() => MapState();
}

class MapState extends State<MapApp> {
  //Services and Cameras
  bool showVisibleAlert = false;
  late dynamic listings = [];
  late String? _mapStyle = '';
  late Listing? listingObj = new Listing();
  late Listing? listingTin = new Listing();
  late google.GoogleMapController? mapController;
  Listing listingClicked = new Listing();

  late google.CameraPosition? _initialPosition;
  late google.CameraPosition? _currentPosition = google.CameraPosition(
      target: google.LatLng(this.widget.latitude, this.widget.longitude),
      zoom: 11);

  // Polygons and Markers
  Set<google.Marker> _markers = {};
  // Set<Polygon> _polygons = {};
  bool loading = false;
  double pinPillPosition = -500;
  double zoomTest = 8;
  List<Place> items = List.empty(growable: true);
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: google.LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  google.MapType _currentMapType = google.MapType.normal;
  bool hideButtons = false;

  // Sliding Up Panel
  double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;
  late final ScrollController scrollController;
  late final PanelController panelController;
  CustomerModel customer = CustomerModel.empty();

  @override
  initState() {
    scrollController = ScrollController();
    panelController = PanelController();
    _fabHeight = _initFabHeight;
    initMap();
    super.initState();
  }

  @override
  void didUpdateWidget(MapApp oldWidget) {
    updateCameraFromHomePage(
        widget.latitude, widget.longitude, widget.request.nZoom!);
    print("did update widget");

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    scrollController.dispose();
    mapController!.dispose();
    super.dispose();
  }

  initMap() {
    _initialPosition = google.CameraPosition(
        target: google.LatLng(this.widget.latitude, this.widget.longitude),
        zoom: this.widget.request.nZoom.toString() != ''
            ? double.parse(this.widget.request.nZoom.toString())
            : 11);
    rootBundle.loadString('assets/map_style.txt').then(
      (string) {
        _mapStyle = string;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildGoogleMap(context),
        MapPreviewComponent(
          showProfile: true,
          pinPillPosition: this.pinPillPosition,
          currentlySelectedPin: this.currentlySelectedPin,
          listing: this.listingObj!,
          callbackOpenProfile: (response) {
            if (response != null) {
              setState(() {
                customer = response.item1;
                listingTin = response.item2;
              });
              this.panelController.animatePanelToSnapPoint(
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            }
          },
        )
      ],
    );
  }

  Widget getBody() {
    return google.GoogleMap(
        minMaxZoomPreference: google.MinMaxZoomPreference(3.5, 13),
        mapType: _currentMapType,
        buildingsEnabled: false,
        tiltGesturesEnabled: true,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        indoorViewEnabled: false,
        trafficEnabled: false,
        padding: Platform.isIOS
            ? EdgeInsets.only(bottom: 80, top: 0, right: 0, left: 0)
            : EdgeInsets.only(bottom: 80, top: 0, right: 0, left: 0),
        mapToolbarEnabled: false,
        initialCameraPosition: _initialPosition!,
        onMapCreated: _onMapCreated,
        markers: _markers,
        // polygons: _polygons,
        onTap: (argument) {
          setState(() {
            this.pinPillPosition = -500;
            this.currentlySelectedPin = PinInformation(
                pinPath: '',
                avatarPath: '',
                location: google.LatLng(0, 0),
                locationName: '',
                labelColor: Colors.grey);
          });
        },
        onCameraMove: onCameraMove,
        onCameraIdle: updateMap);
  }

  _onMapCreated(google.GoogleMapController controller) {
    setState(() {
      mapController = controller;
      controller.setMapStyle(_mapStyle);
    });
    updateMap();
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            onPanelOpened: () {
              setState(() {
                if (this.panelController.isPanelOpen == true) {
                  pinPillPosition = -500;
                  hideButtons = true;
                }
              });
            },
            onPanelClosed: () {
              setState(() {
                if (this.panelController.isPanelAnimating == false) {
                  pinPillPosition = 13;
                  hideButtons = false;
                } else {
                  pinPillPosition = -500;
                  hideButtons = true;
                }
              });
            },
            snapPoint: .54,
            disableDraggableOnScrolling: false,
            maxHeight: MediaQuery.of(context).size.height * .788,
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
                listing: listingTin,
                customer: customer,
                scrollController: scrollController,
                panelController: panelController,
                removeTop: true,
              );
            },
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
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
          Visibility(
              visible: loading == true,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    padding: EdgeInsets.only(bottom: 70),
                    child: Container(
                        height: 30.0,
                        width: 30.0,
                        child: CircularProgressIndicator(
                          color: headerColor,
                          strokeWidth: 2,
                        ))),
              )),
          Visibility(
            visible: this.showVisibleAlert == true,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(top: Platform.isIOS ? 108 : 94),
                child: AnimatedOpacity(
                  opacity: this.showVisibleAlert ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 2000),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        this.widget.request.nZoom = 9;
                        zoomTest = 9;
                        _currentPosition = new google.CameraPosition(
                            target: google.LatLng(
                                _currentPosition!.target.latitude,
                                _currentPosition!.target.longitude),
                            zoom: 10.0);
                      });
                      mapController!.animateCamera(
                          google.CameraUpdate.newLatLngZoom(
                              google.LatLng(_currentPosition!.target.latitude,
                                  _currentPosition!.target.longitude),
                              10));
                    },
                    child: Container(
                      height: 40.0,
                      width: 290.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[400]!,
                                blurRadius: 7,
                                offset: Offset(0, 3))
                          ],
                          border: Border.all(color: Colors.grey[300]!)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Zoom Out To See Private Listings",
                                style: TextStyle(
                                    color: headerColor, fontSize: 16)),
                            SizedBox(width: 5),
                            Icon(Icons.touch_app,
                                color: Colors.red[600], size: 25, fill: 1.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: this.hideButtons == false,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(bottom: 140, left: 15),
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      heroTag: "current_location",
                      backgroundColor: Colors.white.withOpacity(0.9),
                      onPressed: () async {
                        await AnalitysService().sendAnalyticsEvent(
                            'go_to_my_location_click', {
                          "screen_view": "map_screen",
                          "item_id": 'empty',
                          'item_type': 'empty'
                        });
                        var locationData = await getCurrentLocation();
                        mapController!.animateCamera(
                            google.CameraUpdate.newLatLngZoom(
                                google.LatLng(locationData.latitude,
                                    locationData.longitude),
                                9));
                      },
                      child: Image.asset(
                          "assets/images/icons/my_locationPNG.png",
                          height: 24,
                          width: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: this.hideButtons == false,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(bottom: 55, left: 10),
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      heroTag: "add-home",
                      backgroundColor: Colors.white.withOpacity(0.9),
                      onPressed: () async {
                        await AnalitysService().sendAnalyticsEvent(
                            'create_listing_from_map_click', {
                          "screen_view": "map_screen",
                          "item_id": 'new_listing',
                          'item_type': 'empty'
                        });
                        Listing objL = initialData();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CreationWizard(
                                title: 'Listing Creation',
                                fromDraft: false,
                                listing: objL,
                                enableComponents: true,
                                cleanWizardOffside: true,
                                validAddress: false,
                                selectedIndex: 0)));
                      },
                      child: Image.asset("assets/images/icons/add.png",
                          height: 25, width: 25),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Method called on camera move
  void onCameraMove(google.CameraPosition position) {
    if (position.zoom > 12.25) {
      setState(() {
        this.showVisibleAlert = true;
      });
    } else {
      setState(() {
        this.showVisibleAlert = false;
      });
    }

    setState(() {
      this.widget.request.nZoom = position.zoom;
      zoomTest = position.zoom;
      _currentPosition = position;
    });
  }

  void updateMap() {
    Future.delayed(Duration.zero, () async {
      await _updateClusters();
    });
  }

  Future<bool> _updateClusters() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    var mapMarkers = await requestListings();

    if (mounted) {
      setState(() {
        loading = false;
      });
    }

    var markers = List.empty(growable: true);
    if (mapMarkers != null) {
      final list = mapMarkers.length > 0
          ? mapMarkers.cast<dynamic>()
          : List.empty(growable: true);

      for (var item in list) {
        google.Marker marker = await _basicMarkerBuilder(item);
        markers.add(marker);
      }
    }
    updateMarkers(markers);
    return true;
  }

  requestListings() async {
    google.LatLngBounds bounds = await mapController!.getVisibleRegion();

    if (bounds.northeast.longitude != 0.0 && bounds.southwest.latitude != 0.0) {
      writeOnMemory(bounds.northeast.longitude, bounds.northeast.latitude,
          bounds.southwest.longitude, bounds.southwest.latitude);
      listings = List.empty(growable: true);
      ResponseService result =
          await ListingFacade().getlystings(this.widget.request);

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
        if (result.bSuccess!) {
          setState(() {
            listings = result.data.list;
          });
        }
      }

      if (_currentPosition != null) {
        this.widget.callback(_currentPosition!);
      }
    }

    return listings;
  }

  Future<google.Marker> Function(Listing) get _basicMarkerBuilder =>
      (listing) async {
        var color = Colors.black;
        switch (listing.sLystingStatus) {
          case 'For Sale':
            color = Color.fromARGB(255, 21, 96, 25);
            break;
          case 'Pending':
            color = Color.fromARGB(255, 227, 148, 22);
            break;
          case 'Sold':
            color = Color.fromARGB(255, 152, 12, 12);
            break;
        }

        return google.Marker(
          markerId: google.MarkerId(
              listing.sLatitud.toString() + "_" + listing.sLongitud.toString()),
          position: google.LatLng(listing.sLatitud!, listing.sLongitud!),
          onTap: () {
            if (!listing.isCluster!) {
              setState(() {
                this.listingClicked = listing;
                this.pinPillPosition = 13;
                this.listingObj = listing;
                this.currentlySelectedPin = PinInformation(
                  locationName:
                      "\$${NumberFormat.compact().format(listing.nCurrentPrice)}",
                  location:
                      google.LatLng(listing.sLatitud!, listing.sLongitud!),
                  pinPath: listing.sResourcesUrl.length > 0
                      ? listing.sResourcesUrl[0]
                      : '',
                  avatarPath: "assets/images/friend1.jpg",
                  labelColor: Colors.blueAccent,
                  year: listing.nYearBuilt.toString(),
                  size: listing.nSqft.toString(),
                  propertyCondition: listing.sPropertyCondition != null
                      ? listing.sPropertyCondition
                      : 'Average',
                  isInMLS:
                      listing.sIsInMLS != null ? listing.sIsInMLS : 'False',
                  beenSold:
                      listing.sTypeOfSell != null ? listing.sTypeOfSell : '',
                  callback: (val) => setState(
                    () {
                      this.pinPillPosition = val.toDouble();
                      this.listingObj = null;
                    },
                  ),
                );
              });
            } else {
              setState(() {
                this.widget.request.nZoom = this.widget.request.nZoom! + 1;
              });

              mapController!.animateCamera(google.CameraUpdate.newLatLngZoom(
                  google.LatLng(listing.sLatitud!, listing.sLongitud!),
                  this.widget.request.nZoom!.toDouble()));
            }
          },
          icon: listing.isCluster == true
              ? await AdHelper.getClusterBitmap(
                  Platform.isIOS == true ? 150 : 130,
                  text: NumberFormat.compact()
                      .format(listing.pointCount)
                      .toString())
              : await AdHelper.getMarkerIcon(
                  NumberFormat.compact()
                      .format(listing.nCurrentPrice)
                      .toString(),
                  color,
                  listing.sNewMarker!,
                  listing.bIsPrivated!),
        );
      };

  updateMarkers(markers) {
    final Set<google.Marker> markersSet = Set.from(markers);
    this._markers.clear();
    if (mounted) {
      setState(() {
        this._markers = markersSet;
      });
    }
  }

  writeOnMemory(double sEastLng, double sNorthLat, double sWestLng,
      double sSouthLat) async {
    UserRepository userRepository = UserRepository();

    this.widget.request.sEastLng = sEastLng;
    this.widget.request.sNorthLat = sNorthLat;
    this.widget.request.sWestLng = sWestLng;
    this.widget.request.sSouthLat = sSouthLat;

    await userRepository.writeToken('sEastLng', sEastLng.toString());
    await userRepository.writeToken('sNorthLat', sNorthLat.toString());
    await userRepository.writeToken('sWestLng', sWestLng.toString());
    await userRepository.writeToken('sSouthLat', sSouthLat.toString());
    await userRepository.writeToken(
        'nZoom', this.widget.request.nZoom.toString());
  }

  updateCameraFromHomePage(double latitude, double longitude, double zoom) {
    mapController!.animateCamera(google.CameraUpdate.newLatLngZoom(
        google.LatLng(latitude, longitude), zoom));
  }

  initialData() {
    return new Listing(
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
        sTags: []);
  }
}
