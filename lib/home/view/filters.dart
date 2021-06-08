import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/material.dart';

import 'dialog_filters_widget.dart';

Future<SearchFilterModel> filtersDialog (BuildContext context,SearchFilterModel filterModel) async {
  final builder = (BuildContext ctx) =>FiltersWidget(filterModel: filterModel);

  return showDialog(context: context, builder: builder).then((model){
    if (model is SearchFilterModel){
      return model;
    }
    else return null;
  });
}