import 'package:another_flushbar/flushbar.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/my_listings/list.my_listings.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/creation_wizard_house.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/draft.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../models/listing/search/listing.dart';
import 'draft.my_listings.component.dart';

class MyListings extends StatefulWidget {
  @override
  _MyListingsState createState() => _MyListingsState();
}

class _MyListingsState extends State<MyListings> {
  UserRepository userRepo = new UserRepository();
  List<String>? _suggestions = List<String>.empty(growable: true);
  List<Listing>? baseListings = List<Listing>.empty(growable: true);
  List<Listing> listings = List<Listing>.empty(growable: true);
  List<Draft> basedrafts = List<Draft>.empty(growable: true);
  List<Draft> drafts = List<Draft>.empty(growable: true);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchValue = '';
  String status = 'For Sale';
  String title = '';
  bool loading = false;
  bool showSearch = false;
  bool showDrafts = false;
  bool showContainer = false;
  int forSaleTotal = 0;
  int pendingTotal = 0;
  int soldTotal = 0;
  int reviewTotal = 0;
  int requireChangesTotal = 0;
  int deniedTotal = 0;
  int draftTotal = 0;
  Listing newListing = new Listing();

  @override
  void initState() {
    initialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });
    Future.delayed(Duration.zero, () async {
      title = status;
      await requestListings();
      await requestDrafts();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(MyListings oldWidget) {
    Future.delayed(Duration.zero, () async {
      String loadMyListings = await userRepo.readKey('loadMyListings');
      String loadMyDrafts = await userRepo.readKey('loadMyDrafts');
      if (loadMyListings == 'true') {
        await userRepo.writeToken('loadMyListings', '');
        await requestListings();
      }
      if (loadMyDrafts == 'true') {
        await userRepo.writeToken('loadMyDrafts', '');
        await requestDrafts();
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: EasySearchBar(
        actions: [
          GestureDetector(
            onTap: () async {
              //Refresh
              await Future.delayed(Duration(milliseconds: 200), () {
                setState(() {
                  showContainer = true;
                });
              });
              await requestListings();
            },
            child: Container(
                margin: EdgeInsets.only(top: 9),
                child: Icon(Icons.refresh, color: Colors.white)),
          ),
          SizedBox(
            width: 12,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 500),
                    child: CreationWizard(
                        title: 'New Listing Creation',
                        fromDraft: false,
                        listing: this.newListing,
                        enableComponents: true,
                        cleanWizardOffside: true,
                        validAddress: false,
                        selectedIndex: 0),
                  )).then((value) async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                  });
                });
                await requestListings();
              }).catchError((error) {});
            },
            child: Container(
                margin: EdgeInsets.only(top: 5),
                child: Icon(Icons.add, color: Colors.white, size: 30)),
          )
        ],
        suggestions: _suggestions,
        searchHintText: 'Find listings by zip code',
        backgroundColor: headerColor,
        searchCursorColor: headerColor,
        searchBackIconTheme: IconThemeData(color: headerColor),
        appBarHeight: 52,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Listings',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        onSuggestionTap: (data) {
          setState(() {
            this.searchValue = data;
            showContainer = true;
            this.listings = List<Listing>.empty(growable: true);
            this.title = 'Zip Code: $searchValue';
          });
          searchByZipCode(this.searchValue);
        },
        onSearch: (value) => setState(() => this.searchValue = value),
      ),
      body: Container(
        child: showDrafts == false
            ? showContainer == true
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                      ),
                    ),
                  )
                : MyListingsList(
                    listings: this.listings,
                    status: this.title,
                    callbackRemoveListing: (val) async {
                      await Future.delayed(
                        Duration(milliseconds: 200),
                        () {
                          setState(() {
                            showContainer = true;
                          });
                        },
                      );
                      await requestListings();
                    },
                  )
            : DraftstList(
                loading: false,
                drafs: drafts,
                callbackRemoveListing: (val) async {
                  await requestDrafts();
                },
              ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          children: [
            Text(
              'Listings Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: Colors.grey[600], thickness: 1, height: 30),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('In Review',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.reviewTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                    this.listings = List<Listing>.empty(growable: true);
                    showDrafts = false;
                    this.status = 'In Review';
                    this.title = this.status;
                  });
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Required Changes',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.requireChangesTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                    this.listings = List<Listing>.empty(growable: true);
                    showDrafts = false;
                    this.status = 'Required Changes';
                    this.title = this.status;
                  });
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            Divider(color: Colors.grey[600], thickness: 1, height: 30),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('For Sale',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.forSaleTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                    showDrafts = false;
                    this.status = 'For Sale';
                    this.title = this.status;
                  });
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pending',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.yellow[800],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.pendingTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                    this.listings = List<Listing>.empty(growable: true);
                    showDrafts = false;
                    this.status = 'Pending';
                    this.title = this.status;
                  });
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sold',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.soldTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    showContainer = true;
                    this.listings = List<Listing>.empty(growable: true);
                    showDrafts = false;
                    this.status = 'Sold';
                    this.title = this.status;
                  });
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            Divider(color: Colors.grey[600], thickness: 1, height: 30),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Draft',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.draftTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () {
                setState(() {
                  showDrafts = true;
                  this.status = 'Draft';
                  this.title = this.status;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Denied',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    Container(
                      width: 48,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          this.deniedTotal.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ]),
              onTap: () async {
                setState(() {
                  showContainer = true;
                  this.listings = List<Listing>.empty(growable: true);
                  showDrafts = false;
                  this.status = 'Denied';
                  this.title = this.status;
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
            Divider(color: Colors.grey[600], thickness: 1, height: 30),
            ListTile(
              title:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                    onTap: () async {
                      final Uri _url =
                          Uri.parse('https://zeamless.io/#/guidelines');
                      if (await canLaunchUrl(_url)) {
                        await launchUrl(_url);
                      } else {
                        // can't launch url
                      }
                    },
                    child: Container(
                      width: 130,
                      height: 30,
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Listing Guidelines',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )),
              ]),
              onTap: () async {
                setState(() {
                  showContainer = true;
                  this.listings = List<Listing>.empty(growable: true);
                  showDrafts = false;
                  this.status = 'Denied';
                });
                changeStatus(this.status);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  requestListings() async {
    setState(() {
      loading = true;
    });

    ResponseService response = await ListingFacade().getMyListings();

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

    if (response.bSuccess!) {
      setState(() {
        this.baseListings = response.data.list.length > 0
            ? response.data.list.cast<Listing>()
            : List<Listing>.empty(growable: true);
        this.listings = this.baseListings!;
        this.forSaleTotal = response.data.nTotalForSale;
        this.pendingTotal = response.data.nTotalPending;
        this.soldTotal = response.data.nTotalSold;
        this.requireChangesTotal = response.data.nTotalActionReq;
        this.reviewTotal = response.data.nTotalOnReview;
        this.deniedTotal = response.data.nTotalDenied;

        changeStatus(this.status);

        this._suggestions = this
            .baseListings!
            .where((element) => element.sLogicStatus! == 'Live')
            .map((e) => e.sZipCode!)
            .toSet()
            .toList();
      });
    }

    setState(() {
      loading = false;
    });

    return this.listings;
  }

  requestDrafts() async {
    setState(() {
      loading = true;
    });

    ResponseService response = await ListingFacade().getDrafts();

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

    setState(() {
      if (response.bSuccess!) {
        this.basedrafts = response.data.list.length > 0
            ? response.data.list.cast<Draft>()
            : List<Draft>.empty(growable: true);
      }
      this.drafts = this.basedrafts;
      this.draftTotal = this.drafts.length;
      loading = false;
    });

    return this.drafts;
  }

  changeStatus(String statusObj) async {
    List<Listing> listingsRet = List<Listing>.empty(growable: true);
    switch (statusObj) {
      case 'For Sale':
        listingsRet = this
            .baseListings!
            .where((element) =>
                element.sLystingStatus == 'For Sale' &&
                element.sLogicStatus == 'Live')
            .toList();

        break;
      case 'Pending':
        listingsRet = this
            .baseListings!
            .where((element) =>
                element.sLystingStatus == 'Pending' &&
                element.sLogicStatus == 'Live')
            .toList();
        break;
      case 'Sold':
        listingsRet = this
            .baseListings!
            .where((element) =>
                element.sLystingStatus == 'Sold' &&
                element.sLogicStatus == 'Live')
            .toList();
        break;
      case 'In Review':
        listingsRet = this
            .baseListings!
            .where((element) =>
                element.sLogicStatus == 'FreshSt1' ||
                element.sLogicStatus == 'FreshUpdSt3' ||
                element.sLogicStatus == 'LiveUpdSt4')
            .toList();
        break;
      case 'Required Changes':
        listingsRet = this
            .baseListings!
            .where((element) =>
                element.sLogicStatus == 'ActionReqSt2' ||
                element.sLogicStatus == 'LiveActionReqSt5')
            .toList();
        break;
      case 'Denied':
        listingsRet = this
            .baseListings!
            .where((element) => element.sLogicStatus == 'Deny')
            .toList();
        break;
    }
    setState(() {
      this.listings = listingsRet;
    });
    await Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        showContainer = false;
        this.listings = listingsRet;
      });
    });
  }

  searchByZipCode(String zipcode) async {
    List<Listing> listingsRet = List<Listing>.empty(growable: true);

    listingsRet = this
        .baseListings!
        .where((element) =>
            element.sZipCode == zipcode && element.sLogicStatus == 'Live')
        .toList();

    await Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        showContainer = false;
        this.listings = listingsRet;
      });
    });
  }

  initialData() {
    setState(() {
      this.newListing = new Listing(
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
          sTags: [],
          sLystingCategory: '');
    });
  }
}
