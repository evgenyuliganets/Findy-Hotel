
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/home/view/filters.dart';
import 'package:find_hotel/home/view/sliver_app_bar.dart';
import 'package:find_hotel/home/view/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'detail_place_page.dart';

CustomScrollView buildListOfPlaces(
    String textFieldText, List<PlacesDetail> places, String googleApiKey,BuildContext context) {
  var filters= SearchFilterModel();
  return CustomScrollView(slivers: [
    searchSliverAppBar(googleApiKey, textFieldText, filters, context),
    SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => HomeBloc(HomeDataRepository()),
                    child: DetailedPlace(places[index].placeId),
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 15, left: 5, right: 5),
              borderOnForeground: true,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                places[index].photos.isNotEmpty
                    ? Image(
                        image: places[index].photos.first,
                        height: 250,
                        width: 350,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              color: Colors.black12,
                              height: 250,
                              width: 350,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black26),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              ));
                        },
                      )
                    : Image.asset('assets/no_image.jpg',
                        height: 250,
                        width: 350,
                      ),
                ListTile(
                  title: places[index].name == null
                      ? Container()
                      : RichText(
                          text: TextSpan(
                              text: '${places[index].name}',
                              style: TextStyle(
                                color: Color(0xff212121),
                                fontSize: 20,
                              ))),
                  subtitle: places[index].rating == 0 ||
                          places[index].rating == null ||
                          places[index].rating.isNaN
                      ? Row(
                          children: [
                            Row(
                              children: List.generate(5, (ind) {
                                return Icon(
                                  Icons.star_border,
                                  color: Colors.black26,
                                  size: 15,
                                );
                              }),
                            ),
                            Text(
                              ' No Rating',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Row(
                              children: List.generate(5, (ind) {
                                return Icon(
                                  ind + 1 <= places[index].rating
                                      ? Icons.star
                                      : places[index].rating % 1 <= 0.3 ||
                                              ind > places[index].rating
                                          ? Icons.star_border
                                          : Icons.star_half,
                                  color: Colors.amber,
                                  size: 15,
                                );
                              }),
                            ),
                            Text(places[index].rating.toString(),
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: places[index].vicinity == null
                      ? Container(
                          padding: EdgeInsets.all(0),
                        )
                      : RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          text: TextSpan(
                              style: TextStyle(color: Color(0xff5a5a5a)),
                              text: places[index].vicinity)),
                ),
                Container(
                  height: 5,
                ),
              ]),
            ));
      },
      childCount: places.length,
    ))
  ]);
}