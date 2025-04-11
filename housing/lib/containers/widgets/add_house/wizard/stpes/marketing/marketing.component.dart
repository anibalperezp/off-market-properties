import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/search/listing.dart';

class Marketing extends StatefulWidget {
  Marketing(
      {Key? key,
      required this.callback,
      required this.callbackSelectedIndex,
      required this.listing,
      required this.selectedIndex})
      : super(key: key);

  ValueChanged<Listing>? callback;
  ValueChanged<int>? callbackSelectedIndex;
  Listing? listing;
  int? selectedIndex;

  @override
  State<Marketing> createState() => _MarketingState();
}

class _MarketingState extends State<Marketing> {
  List<bool> checked = List.generate(5, (index) => false);
  bool bNetworkBlast = false;
  bool bBoostOnPlatforms = false;
  BuildContext? dialogContext;

  @override
  void initState() {
    this.bNetworkBlast = this.widget.listing!.bNetworkBlast!;
    this.bBoostOnPlatforms = this.widget.listing!.bBoostOnPlatforms!;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Marketing oldWidget) {
    if (this.widget.listing!.sTypeOfSell != oldWidget.listing!.sTypeOfSell!) {
      this.widget.listing!.bNetworkBlast = this.bNetworkBlast;
      this.widget.listing!.bBoostOnPlatforms = this.bBoostOnPlatforms;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post in Facebook Marketplace Group
          Row(
            children: <Widget>[
              Switch(
                value: this.bNetworkBlast,
                activeColor: headerColor,
                onChanged: (value) {
                  setState(() {
                    this.bNetworkBlast = value;
                    this.widget.listing!.bNetworkBlast = this.bNetworkBlast;
                    this.widget.callback!(this.widget.listing!);
                  });
                },
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  "Network Blast",
                  style: TextStyle(
                      fontSize: 18,
                      color: headerColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Notify all my connections about this listing via email, in-app notifications, and push notifications.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700]!,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Post in Craighlist platform
          Row(
            children: <Widget>[
              Switch(
                value: this.bBoostOnPlatforms,
                activeColor: headerColor,
                onChanged: (value) {
                  setState(() {
                    this.bBoostOnPlatforms = value;
                    this.widget.listing!.bBoostOnPlatforms =
                        this.bBoostOnPlatforms;
                    this.widget.callback!(this.widget.listing!);
                  });
                },
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  "Boost My Listing",
                  style: TextStyle(
                      fontSize: 18,
                      color: headerColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Turn it on and watch us boost your sales by attracting buyers from the internet into your Zeamless network, all hands-free for you.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700]!,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            "How does it work?",
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[900]!,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "A preview of your listing is actively promoted on multiple platforms, including a quick-access link to the property. When interested buyers access your listing on the app through that link, they are instantly added to your list of connections, which opens up additional opportunites, such as:",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700]!,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5, // horizontal space between children
            children: [
              Text(
                "Real-Time Chat:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[900]!,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Your connections can message you about the property, or you can use it to initiate a conversation.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700]!,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 10,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5, // horizontal space between children
            children: [
              Text(
                "Instant Profile Access:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[900]!,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "They have quick access to your profile, including all your listings, allowing them to stay updated with your activity...",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700]!,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5, // horizontal space between children
            children: [
              Text(
                "Listing Alerts:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[900]!,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Your connections will automatically receive updates about listing changes and new listing alerts... ",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700]!,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "In our efforts to attract buyers outside of Zeamless to your listing, we may promote a preview using various methods and platforms. These include an email blast to the Zeamless investor network, Facebook Marketplace, Facebook Investment Groups, Facebook Pages, Craigslist, LinkedIn, Instagram, and YouTube. By turning on this feature, you grant us temporary permission to promote a preview of your listing until you mark it as pending or sold.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700]!,
            ),
          ),
        ],
      ),
    );
  }
}
