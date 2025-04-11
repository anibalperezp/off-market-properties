import 'package:flutter/material.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class ButtonGroupSpaced extends StatefulWidget {
  final oneOnly;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final List<String>? items;
  List<String>? selectedItems;
  ValueChanged<dynamic>? callback;
  ButtonGroupSpaced(
      {this.oneOnly,
      this.selectedColor,
      this.selectedTextColor,
      this.items,
      this.selectedItems,
      this.callback});

  @override
  _ButtonGroupSpacedState createState() => _ButtonGroupSpacedState();
}

class _ButtonGroupSpacedState extends State<ButtonGroupSpaced> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: this.widget.items!.map((item) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (this.widget.oneOnly) {
                  this.widget.selectedItems = List.empty(growable: true);
                  this.widget.selectedItems!.add(item);
                } else {
                  if (this
                      .widget
                      .selectedItems!
                      .any((element) => item == element && element != "Any")) {
                    this.widget.selectedItems!.remove(item);
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
                    if (item == "Any") {
                      setState(() {
                        this.widget.selectedItems = List.empty(growable: true);
                      });
                    }
                    this.widget.selectedItems!.add(item);
                    if (this.widget.selectedItems!.length ==
                        this.widget.items!.length - 1) {
                      this.widget.selectedItems!.clear();
                      this.widget.selectedItems!.add("Any");
                    }
                  }
                }
                this.widget.callback!(this.widget.selectedItems);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
              decoration: BoxDecoration(
                color: isSelected(item)
                    ? item == "Any"
                        ? Color.fromRGBO(157, 160, 163, 1)
                        : this.widget.selectedColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: Text(
                getTypeOfSell(item),
                style: TextStyle(
                    fontSize: 14,
                    color: isSelected(item)
                        ? item == "Any"
                            ? Colors.white
                            : Colors.white
                        : buttonsColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  isSelected(String item) {
    return this.widget.selectedItems!.any((element) => element == item);
  }
}
