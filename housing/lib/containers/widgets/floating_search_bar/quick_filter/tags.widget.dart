import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class TagsWidget extends StatefulWidget {
  final FilterProvider filterProvider;
  final ValueChanged<List>? callback;
  const TagsWidget(
      {Key? key, required this.filterProvider, required this.callback})
      : super(key: key);

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  List<MultiSelectItem<dynamic>> _items = [];
  List<dynamic> _selectedTags = [];

  @override
  void initState() {
    _selectedTags = widget.filterProvider.filterModel!.sTags ?? [];

    for (var tag in widget.filterProvider.filterSettingsModel!.sTags) {
      _items.add(MultiSelectItem(tag, tag.toString()));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MultiSelectBottomSheetField(
          initialValue: _selectedTags,
          initialChildSize: 0.6,
          listType: MultiSelectListType.CHIP,
          searchable: true,
          itemsTextStyle: TextStyle(fontSize: 17),
          searchHintStyle: TextStyle(fontSize: 17),
          buttonIcon: Icon(Icons.add_circle, color: headerColor, size: 28),
          buttonText: Text(
            "Select Tags",
            style: TextStyle(fontSize: 18),
          ),
          title: Text(
            "Tags",
            style: TextStyle(fontSize: 21),
          ),
          items: _items,
          selectedColor: headerColor,
          checkColor: Colors.white,
          selectedItemsTextStyle: TextStyle(color: Colors.white, fontSize: 16),
          onConfirm: (values) {
            setState(() {
              _selectedTags = values.cast<dynamic>();
              // _items = _selectedTags
              //     .map((tag) => MultiSelectItem(tag, tag.toString()))
              //     .toList();
            });
            widget.callback!(_selectedTags);
          },
          chipDisplay: MultiSelectChipDisplay(
            onTap: (value) {
              setState(() {
                _selectedTags.remove(value);
                // _items.removeWhere((item) => item.value == value);
              });
            },
          ),
        ),
        _selectedTags.isEmpty
            ? Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "No Tags Are Selected",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : Container(),
      ],
    );
  }
}
