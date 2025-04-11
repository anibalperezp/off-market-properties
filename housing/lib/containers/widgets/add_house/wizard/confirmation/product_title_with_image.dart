import 'package:flutter/material.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:intl/intl.dart';

class ProductTitleWithImage extends StatelessWidget {
  const ProductTitleWithImage({
    Key? key,
    @required this.listing,
  }) : super(key: key);

  final Listing? listing;

  @override
  Widget build(BuildContext context) {
    final oCcy = new NumberFormat("#,###", "en_US");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          Text(
            listing!.sPropertyAddress!,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 2),
          Text(
            listing!.sPropertyType!,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
          ),
          SizedBox(height: 15),
          Row(
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: "${listing!.uLystingId}",
                  child: Image.asset(
                    "assets/images/house-test.jpeg", //TODO: listing.images[0].
                    fit: BoxFit.fill,
                    height: 160,
                    width: 80,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Text(
            listing!.nFirstPrice == null
                ? "Price: 0"
                : "Price: \$${oCcy.format(listing!.nFirstPrice)}",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
