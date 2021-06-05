import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/material.dart';

import 'dialog_filters_widget.dart';

Future<SearchFilterModel> filtersDialog (BuildContext context) async {
  final builder = (BuildContext ctx) =>FiltersWidget(

  );

  return showDialog(context: context, builder: builder);
}