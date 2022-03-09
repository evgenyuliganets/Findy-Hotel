import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/view/detail_place_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

ListView buildProfileListOfPlaces(List<PlacesDetail> places) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: places.length,
      itemBuilder: (BuildContext context, int index) {
       return SingleChildScrollView(
         physics: NeverScrollableScrollPhysics(),
         child: Container(
           width: 300,
           height: 480,
           child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => HomeBloc(HomeDataRepository(context)),
                      child: DetailedPlace(places[index].placeId),
                    ),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
                borderOnForeground: true,
                child: Column(
                    mainAxisSize: MainAxisSize.min, children: <Widget>[
                  places[index].photos.isNotEmpty
                      ? Image(
                          image: places[index].photos.first,
                          fit: BoxFit.fill,
                          height: 250,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                color: Colors.black12,
                                height: 250,
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
                      : Image.asset(
                          'assets/no_image.jpg',
                          height: 250,

                        ),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    title: places[index].name == null
                        ? SizedBox.shrink()
                        : RichText(
                            text: TextSpan(
                                text: '${places[index].name}',
                                style: TextStyle(
                                  color: Color(0xff212121),
                                  fontSize: 23,
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
                        ? RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            text: TextSpan(
                                style: TextStyle(color: Color(0xff5a5a5a)),
                                text: places[index].formattedAddress))
                        : RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            text: TextSpan(
                                style: TextStyle(color: Color(0xff5a5a5a)),
                                text: places[index].vicinity)),
                  ),
                  if(places[index].types!=null)
                  Container(
                    height: 2,
                  ),
                  places[index].types!=null
                      ? Divider(
                          height: 1,
                        )
                      : SizedBox.shrink(),
                  places[index].types!=null
                      ? Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: 40,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: places[index].types.length,
                              itemBuilder: (BuildContext context, int indexTypes) {
                                return Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: FilterChip(
                                      avatar: Image(
                                        image: AssetImage(
                                            'assets/${places[index].types[indexTypes]}' +
                                                '.png'),
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace stackTrace) {
                                          return Image.asset('assets/geocode.png');
                                        },
                                      ),
                                      labelStyle: TextStyle(),
                                      label: Text(
                                          '#' + places[index].types[indexTypes]),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      onSelected: (bool value) {}),
                                );
                              }),
                        )
                      : SizedBox.shrink(),
                  if(places[index].openNow != null ||
                      places[index].priceLevel.isNotEmpty)
                  Divider(height: 1,),
                  places[index].openNow != null ||
                          places[index].priceLevel.isNotEmpty
                      ? Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    places[index].openNow != null
                                        ? places[index].openNow == "true"
                                            ? Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          3)),
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              border: Border.all(
                                                                  color: Color(
                                                                      0xffdbdbdb))),
                                                          height: 30,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 5),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                    'Open Now: ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                    )),
                                                                Text(
                                                                  'Open',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xff4a6540),
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              ])),
                                                      if (places[index]
                                                              .openingHours !=
                                                          null)
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                      if (places[index]
                                                              .openingHours !=
                                                          null)
                                                        Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            3)),
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                border: Border.all(
                                                                    color: Color(
                                                                        0xffdbdbdb))),
                                                            height: 30,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 5,
                                                                    right: 5),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                      'Closes In: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                      )),
                                                                  if (places[index]
                                                                          .openingHours !=
                                                                      null)
                                                                    places[index].openingHours !=
                                                                            'Open 24 hours'
                                                                        ? Text(
                                                                            places[index].openingHours.substring(0, 2) +
                                                                                ':' +
                                                                                places[index].openingHours.substring(2, 4),
                                                                            style: TextStyle(
                                                                                color: Color(0xffa73636),
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold),
                                                                          )
                                                                        : Text(
                                                                            places[index].openingHours,
                                                                            style: TextStyle(
                                                                                color: Color(0xff4a6540),
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold),
                                                                          )
                                                                ])),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          3)),
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              border: Border.all(
                                                                  color: Color(
                                                                      0xffdbdbdb))),
                                                          height: 30,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 5),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  'Open Now: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Closed',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xffa73636),
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                if (places[index]
                                                                        .openingHours !=
                                                                    null)
                                                                  Text(
                                                                      ' | Opens In: '),
                                                                if (places[index]
                                                                        .openingHours !=
                                                                    null)
                                                                  places[index]
                                                                              .openingHours !=
                                                                          'Open 24 hours'
                                                                      ? Text(
                                                                          places[index].openingHours.substring(0, 2) +
                                                                              ':' +
                                                                              places[index].openingHours.substring(2, 4),
                                                                          style: TextStyle(
                                                                              color: Color(0xff4a6540),
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      : Text(
                                                                          places[index]
                                                                              .openingHours,
                                                                          style: TextStyle(
                                                                              color: Color(0xff4a6540),
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                              ])),
                                                    ],
                                                  ),
                                                ],
                                              )
                                        : SizedBox.shrink(),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ],))),
         ),
       );
    },
  );
}
