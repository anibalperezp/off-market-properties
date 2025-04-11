import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class OgTab extends StatefulWidget {
  final List<String>? items;
  List<String>? selectedItems;
  bool? oneOnly;
  ValueChanged<dynamic>? callback;
  OgTab({this.items, this.selectedItems, this.oneOnly, this.callback});

  @override
  _OgTabState createState() => _OgTabState();
}

class _OgTabState extends State<OgTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: List.generate(
          widget.items!.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (this.widget.oneOnly!) {
                    this.widget.selectedItems = List.empty(growable: true);
                    this.widget.selectedItems!.add(widget.items![index]);
                  } else {
                    if (this.widget.selectedItems!.any((element) =>
                        widget.items![index] == element && element != "Any")) {
                      this.widget.selectedItems!.remove(widget.items![index]);
                      if (this.widget.selectedItems!.length == 0) {
                        this.widget.selectedItems!.add("Any");
                      }
                    } else {
                      if (this
                          .widget
                          .selectedItems!
                          .any((element) => element == "Any")) {
                        this.widget.selectedItems!.remove("Any");
                      }
                      if (widget.items![index] == "Any") {
                        setState(() {
                          this.widget.selectedItems =
                              List.empty(growable: true);
                        });
                      }
                      this.widget.selectedItems!.add(widget.items![index]);
                    }
                  }
                  this.widget.callback!(this.widget.selectedItems);
                });
              },
              child: Container(
                height: 47.0,
                decoration: BoxDecoration(
                  color: isSelected(widget.items![index])
                      ? widget.items![index] == "Any"
                          ? Color.fromRGBO(157, 160, 163, 1)
                          : headerColor
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(index == 0 ? 5 : 0),
                    bottomLeft: Radius.circular(index == 0 ? 5 : 0),
                    topRight: Radius.circular(
                        index == (this.widget.items!.length - 1) ? 5 : 0),
                    bottomRight: Radius.circular(
                        index == (this.widget.items!.length - 1) ? 5 : 0),
                  ),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    widget.items![index],
                    style: TextStyle(
                      color: isSelected(widget.items![index])
                          ? Colors.white
                          : buttonsColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  isSelected(String item) {
    return this.widget.selectedItems!.any((element) => element == item);
  }
}
