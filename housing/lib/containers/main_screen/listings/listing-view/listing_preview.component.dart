import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/lot.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/mls.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/multi_family.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-preview/single_family.component.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/referal/customer.model.dart';

class ListingPreview extends StatefulWidget {
  bool appyScroll;
  List<Listing> itemsData;
  ValueChanged<Tuple2<Listing, bool>> onCallback;
  bool isPreviewFavorite;
  ValueChanged<String> callbackRemoveListing;
  ValueChanged<Tuple2<CustomerModel, Listing>> callbackOpenProfile;
  bool isEditMode;
  bool showProfile;

  ListingPreview(
      {Key? key,
      List<Listing>? itemsData,
      ValueChanged<Tuple2<Listing, bool>>? onCallback,
      bool? isPreviewFavorite,
      ValueChanged<String>? callbackRemoveListing,
      ValueChanged<Tuple2<CustomerModel, Listing>>? callbackOpenProfile,
      bool? isEditMode,
      bool? showProfile,
      bool? appyScroll})
      : itemsData = itemsData!,
        onCallback = onCallback!,
        isPreviewFavorite = isPreviewFavorite!,
        callbackRemoveListing = callbackRemoveListing!,
        callbackOpenProfile = callbackOpenProfile!,
        isEditMode = isEditMode!,
        showProfile = showProfile!,
        appyScroll = appyScroll!,
        super(key: key);

  @override
  _ListingPreviewState createState() => _ListingPreviewState();
}

class _ListingPreviewState extends State<ListingPreview> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  double parentHeigh = 0;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0,
      displacement: 120,
      strokeWidth: 3,
      color: headerColor,
      backgroundColor: Colors.white,
      key: _refreshIndicatorKey,
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          widget.callbackRemoveListing('');
        });
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics:
            widget.appyScroll == true ? NeverScrollableScrollPhysics() : null,
        itemCount: widget.itemsData.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          final item = widget.itemsData[index];
          return item.sPropertyType!.isNotEmpty
              ? getListingContentByPropType(item)
              : Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getListingContentByPropType(Listing item) {
    Widget? listingContentByType;

    if (item.bHasZeamlessUser == false) {
      listingContentByType = PrevMLS(
          showStory: false,
          item: item,
          callback: (val) => this.widget.onCallback(val),
          isPreviewFavorite: widget.isPreviewFavorite,
          isEditMode: widget.isEditMode,
          callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
          callbackOpenProfile: (value) {
            this.widget.callbackOpenProfile(value);
          });
    } else {
      switch (item.sPropertyType) {
        case 'Single Family':
          listingContentByType = PrevSingleFamily(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
        case 'Apartment':
          listingContentByType = PrevSingleFamily(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
        case 'Condo':
          listingContentByType = PrevSingleFamily(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
        case 'Townhome':
          listingContentByType = PrevSingleFamily(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
        case 'Lot':
          listingContentByType = PrevLot(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
        case 'Multi-Unit Complex':
          listingContentByType = PrevMultiFamily(
              showProfile: widget.showProfile,
              showStory: false,
              item: item,
              callback: (val) => this.widget.onCallback(val),
              isPreviewFavorite: widget.isPreviewFavorite,
              isEditMode: widget.isEditMode,
              callbackRemoveListing: (val) => widget.callbackRemoveListing(val),
              callbackOpenProfile: (value) {
                this.widget.callbackOpenProfile(value);
              });
          break;
      }
    }
    return listingContentByType;
  }
}
