import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/home/view/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'filters.dart';

Widget searchSliverAppBar(String googleApiKey,String textFieldText,SearchFilterModel filters,BuildContext context){
  return SliverAppBar(
    pinned: true,
    snap: true,
    floating: true,
    shadowColor: Color(0xff9baed5),
    backgroundColor: Color(0xff9baed5),
    expandedHeight: 100,
    title: HomeTextField(
      googleApiKey,
      textFieldText: textFieldText,
      searchFilterModel: filters,
    ),
    flexibleSpace: Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Color(0xff636e86),
        padding: EdgeInsets.only(right: 50,left: 50,bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Ink(
                height: 37,
                width: 37,
                decoration: const ShapeDecoration(
                  color: Color(0xff636e86),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                ),
                child: IconButton(
                  onPressed: () async {
                    filters = await filtersDialog(context);
                  },
                  icon: Icon(
                    Icons.filter_alt,
                    color: Color(0xffd2d2d2),
                  ),
                  iconSize: 22,
                  color: Colors.blueGrey,
                )),
          ],
        ),
      ),
    ),
  );
}