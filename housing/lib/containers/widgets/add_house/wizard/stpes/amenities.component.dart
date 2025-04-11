import 'package:flutter/material.dart';
import 'package:zipcular/commons/data/data.constants.global.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/amenitie.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Amenities extends StatefulWidget {
  Amenities(
      {Key? key,
      this.listing,
      this.callback,
      this.selectedIndex,
      this.callbackSelectedIndex})
      : super(key: key);

  Listing? listing;
  ValueChanged<List<String>>? callback;
  ValueChanged<int>? callbackSelectedIndex;
  int? selectedIndex;

  @override
  _AmenitiesState createState() => _AmenitiesState();
}

class _AmenitiesState extends State<Amenities> {
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  List<dynamic> _items = List.empty(growable: true);
  List<dynamic> _selectedAmenities = List.empty(growable: true);

  @override
  void initState() {
    if (this.widget.listing!.sAmenities!.length > 0) {
      this.widget.listing!.sAmenities!.forEach((item) {
        final ameni = amenitiesConst.firstWhere(
            (cons) => cons.name == item && cons.type == widget.selectedIndex);
        _selectedAmenities.add(ameni);
      });
    }
    this._items = amenitiesConst
        .where((element) => element.type == widget.selectedIndex)
        .map((am) => MultiSelectItem<Amenitie>(am, am.name!))
        .toList();
    super.initState();
  }

  @override
  void didUpdateWidget(Amenities oldWidget) {
    if (oldWidget.listing!.sAmenities != this.widget.listing!.sAmenities) {
      this.widget.listing = oldWidget.listing;
      if (oldWidget.listing!.sAmenities!.length > 0 &&
          this.widget.listing!.sAmenities!.length !=
              oldWidget.listing!.sAmenities!.length) {
        this.widget.listing!.sAmenities!.forEach((item) {
          final ameni = amenitiesConst.firstWhere(
              (cons) => cons.name == item && cons.type == widget.selectedIndex);
          _selectedAmenities.add(ameni);
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          MultiSelectBottomSheetField(
            onSelectionChanged: (p0) {
              int index =
                  propTypes.indexOf(this.widget.listing!.sPropertyType!);
              this.widget.callbackSelectedIndex!(index + 1);
            },
            initialValue: _selectedAmenities,
            initialChildSize: 0.4,
            listType: MultiSelectListType.CHIP,
            searchable: true,
            itemsTextStyle: TextStyle(fontSize: 17),
            searchHintStyle: TextStyle(fontSize: 17),
            buttonIcon: Icon(Icons.add_circle, color: headerColor, size: 28),
            buttonText:
                Text("Select Amenities", style: TextStyle(fontSize: 18)),
            title: Text("Amenities", style: TextStyle(fontSize: 21)),
            items: _items as List<MultiSelectItem<Amenitie>>,
            selectedColor: headerColor,
            selectedItemsTextStyle:
                TextStyle(color: Colors.white, fontSize: 16),
            onConfirm: (values) {
              setState(() {
                this.widget.listing!.sAmenities = List.empty(growable: true);
                values.forEach((element) {
                  Amenitie amenitie = element as Amenitie;
                  this.widget.listing!.sAmenities!.add(amenitie.name!);
                });
                _selectedAmenities = values;
              });
              this.widget.callback!(this.widget.listing!.sAmenities!.toList());
              int index =
                  propTypes.indexOf(this.widget.listing!.sPropertyType!);
              this.widget.callbackSelectedIndex!(index + 1);
            },
            chipDisplay: MultiSelectChipDisplay(
              onTap: (value) {
                setState(() {
                  _selectedAmenities.remove(value);
                });
                int index =
                    propTypes.indexOf(this.widget.listing!.sPropertyType!);
                this.widget.callbackSelectedIndex!(index + 1);
              },
            ),
          ),
          _selectedAmenities.isEmpty
              ? Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "None selected",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
