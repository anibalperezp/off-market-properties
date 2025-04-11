import 'package:flutter/material.dart';
import 'package:zipcular/commons/branch/constants.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';

class DealsWidget extends StatefulWidget {
  final FilterProvider filterProvider;
  final ValueChanged<List>? callback;
  const DealsWidget(
      {Key? key, required this.filterProvider, required this.callback})
      : super(key: key);

  @override
  State<DealsWidget> createState() => _DealsWidgetState();
}

class _DealsWidgetState extends State<DealsWidget> {
  List<String> selected = [];

  @override
  void initState() {
    final selectedDeals = widget.filterProvider.filterModel!.sTypeOfSell;
    selected = List.from(selectedDeals);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        for (var i = 0;
            i < widget.filterProvider.filterSettingsModel!.sTypeOfSell.length;
            i++)
          GestureDetector(
            onTap: () {
              setState(
                () {
                  if (widget
                          .filterProvider.filterSettingsModel!.sTypeOfSell[i] ==
                      'Any') {
                    if (selected.contains('Any')) {
                      selected = [];
                      selected = widget
                          .filterProvider.filterSettingsModel!.sTypeOfSell
                          .where((element) => element != 'Any')
                          .toList();
                    } else {
                      selected = [];
                      selected.add('Any');
                    }
                  } else {
                    if (selected.contains('Any')) {
                      selected = [
                        widget
                            .filterProvider.filterSettingsModel!.sTypeOfSell[i]
                      ];
                    } else {
                      selected.contains(widget.filterProvider
                              .filterSettingsModel!.sTypeOfSell[i])
                          ? selected.remove(widget.filterProvider
                              .filterSettingsModel!.sTypeOfSell[i])
                          : selected.add(widget.filterProvider
                              .filterSettingsModel!.sTypeOfSell[i]);
                      if (selected.length ==
                          widget.filterProvider.filterSettingsModel!.sTypeOfSell
                                  .length -
                              1) {
                        selected = [];
                        selected.add('Any');
                      }
                      if (selected.isEmpty) {
                        selected.add('Any');
                      }
                    }
                  }
                  widget.callback!(selected);
                },
              );
            },
            child: ListTile(
              title: Text(
                getTypeOfSell(
                    widget.filterProvider.filterSettingsModel!.sTypeOfSell[i]),
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                selected.contains(widget
                        .filterProvider.filterSettingsModel!.sTypeOfSell[i])
                    ? Icons.task_alt_outlined
                    : Icons.circle_outlined,
                color: selected.contains(widget
                        .filterProvider.filterSettingsModel!.sTypeOfSell[i])
                    ? headerColor
                    : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
