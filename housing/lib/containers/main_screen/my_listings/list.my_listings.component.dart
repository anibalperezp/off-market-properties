import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_preview.component.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/listing/search_request.dart';

class MyListingsList extends StatefulWidget {
  List<Listing> listings;
  String status;
  ValueChanged<String> callbackRemoveListing;
  MyListingsList(
      {Key? key,
      List<Listing>? listings,
      String? status,
      ValueChanged<String>? callbackRemoveListing})
      : listings = listings!,
        status = status!,
        callbackRemoveListing = callbackRemoveListing!,
        super(key: key);

  @override
  _MyListingsListState createState() => _MyListingsListState();
}

class _MyListingsListState extends State<MyListingsList> {
  SearchRequest? request;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(MyListingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.listings.length == 0 ? 0 : 10),
      color: Colors.white,
      child: widget.listings.length == 0
          ? Center(
              child: EmptyWidget(
                image: null,
                hideBackgroundAnimation: true,
                packageImage: PackageImage.Image_3,
                title:
                    'You have no${' ' + '"' + widget.status + '"'} listings.',
                subTitle:
                    'You can check your listing status by clicking in the hamburger menu icon in the top left corner.',
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                subtitleTextStyle: TextStyle(
                  fontSize: 16,
                  color: Color(0xffabb8d6),
                ),
              ),
            )
          : ListingPreview(
              appyScroll: false,
              showProfile: false,
              callbackOpenProfile: (value) {
                // Don't show profile in my listings
              },
              isPreviewFavorite: false,
              isEditMode: true,
              itemsData: widget.listings != null
                  ? widget.listings.cast<Listing>().toList()
                  : [],
              callbackRemoveListing: (val) async {
                setState(
                  () {
                    widget.callbackRemoveListing(val);
                  },
                );
              },
              onCallback: (val) {},
            ),
    );
  }
}
