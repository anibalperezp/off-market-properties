import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';

class OffMarketWidget extends StatefulWidget {
  final FilterProvider filterProvider;
  final ValueChanged<List>? callback;
  const OffMarketWidget(
      {Key? key, required this.filterProvider, required this.callback})
      : super(key: key);

  @override
  State<OffMarketWidget> createState() => _OffMarketWidgetState();
}

class _OffMarketWidgetState extends State<OffMarketWidget> {
  List<String> selected = [];

  @override
  void initState() {
    final selectedCategory =
        widget.filterProvider.filterModel!.sLystingCategory;
    selected = List.from(selectedCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        for (var i = 0;
            i <
                widget.filterProvider.filterSettingsModel!.sLystingCategory
                    .length;
            i++)
          GestureDetector(
            onTap: () {
              setState(
                () {
                  if (widget.filterProvider.filterSettingsModel!
                          .sLystingCategory[i] ==
                      'Any') {
                    if (selected.contains('Any')) {
                      selected = [];
                      selected = widget
                          .filterProvider.filterSettingsModel!.sLystingCategory
                          .where((element) => element != 'Any')
                          .toList();
                    } else {
                      selected = [];
                      selected.add('Any');
                    }
                  } else {
                    if (selected.contains('Any')) {
                      selected = [
                        widget.filterProvider.filterSettingsModel!
                            .sLystingCategory[i]
                      ];
                    } else {
                      selected.contains(widget.filterProvider
                              .filterSettingsModel!.sLystingCategory[i])
                          ? selected.remove(widget.filterProvider
                              .filterSettingsModel!.sLystingCategory[i])
                          : selected.add(widget.filterProvider
                              .filterSettingsModel!.sLystingCategory[i]);
                      if (selected.length ==
                          widget.filterProvider.filterSettingsModel!
                                  .sLystingCategory.length -
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
                widget.filterProvider.filterSettingsModel!.sLystingCategory[i],
                style: TextStyle(fontSize: 18),
              ),
              leading: Icon(
                selected.contains(widget.filterProvider.filterSettingsModel!
                        .sLystingCategory[i])
                    ? Icons.task_alt_outlined
                    : Icons.circle_outlined,
                color: selected.contains(widget.filterProvider
                        .filterSettingsModel!.sLystingCategory[i])
                    ? headerColor
                    : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
