import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/cubit/save_to_favorite_cubit.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'detail_place_page.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

SliverList buildListOfPlaces(String textFieldText, List<PlacesDetail> places,
    String googleApiKey, BuildContext context) {
  var placesRepo = PlacesRepository();
  return SliverList(
      delegate: SliverChildBuilderDelegate(
    (context, index) {
      return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
            margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
            borderOnForeground: true,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              places[index].photos.isNotEmpty
                  ? Image(
                      image: places[index].photos.first,
                      fit: BoxFit.contain,
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
                                size: 20,
                              );
                            }),
                          ),
                          Text(
                            AppLocalizations.of(context).detailedRatingError,
                            style: TextStyle(fontSize: 12),
                          ),
                          Spacer(),
                          Container(
                            child: BlocProvider(
                              create: (context) => FavoriteCubit(HomeDataRepository()),
                              child: BlocConsumer<FavoriteCubit, FavoriteState>(
                                builder: (context, state) {
                                  if (state is FavoriteLoading) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }else return Container(
                                    padding: EdgeInsets.only(right: 5,bottom: 5),
                                    child: Ink(
                                        height: 40,
                                        width: 45,
                                        decoration: const ShapeDecoration(
                                          color: Color(0xff636e86),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                        ),
                                        child: FutureBuilder<Object>(
                                            future: placesRepo.checkIfExistInFavorite(places[index].placeId),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData){
                                                return IconButton(
                                                  onPressed: () async {
                                                    snapshot.data?
                                                    BlocProvider.of<FavoriteCubit>(context)
                                                        .deleteFromFavoriteSubmitted(places[index].placeId)
                                                        :BlocProvider.of<FavoriteCubit>(context)
                                                        .addToFavoriteSubmitted (places[index].placeId);
                                                  },
                                                  icon: Icon(
                                                    snapshot.data?
                                                    Icons.favorite :Icons.favorite_border,
                                                    color: Color(0xffffffff),
                                                  ),
                                                  iconSize: 22,
                                                  color: Colors.blueGrey,
                                                );
                                              }
                                              if(snapshot.hasError){
                                                return IconButton(
                                                  onPressed: () async {
                                                    snapshot.data?
                                                    BlocProvider.of<FavoriteCubit>(context)
                                                        .deleteFromFavoriteSubmitted(places[index].placeId)
                                                        :BlocProvider.of<FavoriteCubit>(context)
                                                        .addToFavoriteSubmitted (places[index].placeId);
                                                  },
                                                  icon: Icon(
                                                    snapshot.data?
                                                    Icons.favorite :Icons.favorite_border,
                                                    color: Color(0xffd2d2d2),
                                                  ),
                                                  iconSize: 22,
                                                  color: Colors.blueGrey,
                                                );
                                              }
                                              else{
                                                return CircularProgressIndicator();
                                              }
                                            }
                                        )),
                                  );
                                }, listener: (context, state) {
                              if (state is FavoriteError) {
                                if (state.error!=null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(seconds: 2),
                                          content: Text(state.error)));
                                }
                              }
                              if (state is FavoriteLoaded) {
                                if (state.message!=null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(seconds: 2),
                                          content: Text(state.message)));
                                }
                              }
                            }),
),
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
                                size: 20,
                              );
                            }),
                          ),
                          Text(places[index].rating.toString(),
                              style: TextStyle(color: Colors.black54)),
                          Spacer(),
                          Container(
                            child: BlocProvider(
                              create: (context) => FavoriteCubit(HomeDataRepository()),
                              child:BlocConsumer<FavoriteCubit, FavoriteState>(
                                builder: (context, state) {
                                  if (state is FavoriteLoading) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }else return Container(
                                    padding: EdgeInsets.only(right: 5,bottom: 5),
                                    child: Ink(
                                        height: 40,
                                        width: 45,
                                        decoration: const ShapeDecoration(
                                          color: Color(0xff636e86),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                        ),
                                        child: FutureBuilder<Object>(
                                            future: placesRepo.checkIfExistInFavorite(places[index].placeId),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData){
                                                return IconButton(
                                                  onPressed: () async {
                                                    snapshot.data?
                                                    BlocProvider.of<FavoriteCubit>(context)
                                                        .deleteFromFavoriteSubmitted(places[index].placeId)
                                                        :BlocProvider.of<FavoriteCubit>(context)
                                                        .addToFavoriteSubmitted (places[index].placeId);
                                                  },
                                                  icon: Icon(
                                                    snapshot.data?
                                                    Icons.favorite :Icons.favorite_border,
                                                    color: Color(0xffffffff),
                                                  ),
                                                  iconSize: 22,
                                                  color: Colors.blueGrey,
                                                );
                                              }
                                              if(snapshot.hasError){
                                                return IconButton(
                                                  onPressed: () async {
                                                    snapshot.data?
                                                    BlocProvider.of<FavoriteCubit>(context)
                                                        .deleteFromFavoriteSubmitted(places[index].placeId)
                                                        :BlocProvider.of<FavoriteCubit>(context)
                                                        .addToFavoriteSubmitted (places[index].placeId);
                                                  },
                                                  icon: Icon(
                                                    snapshot.data?
                                                    Icons.favorite :Icons.favorite_border,
                                                    color: Color(0xffd2d2d2),
                                                  ),
                                                  iconSize: 22,
                                                  color: Colors.blueGrey,
                                                );
                                              }
                                              else{
                                                return CircularProgressIndicator();
                                              }
                                            }
                                        )),
                                  );
                                }, listener: (context, state) {
                              if (state is FavoriteError) {
                                if (state.error!=null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(seconds: 2),
                                          content: Text(state.error)));
                                }
                              }
                              if (state is FavoriteLoaded) {
                                if (state.message!=null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          duration: const Duration(seconds: 2),
                                          content: Text(state.message)));
                                }
                              }
                            }),
),
                          ),
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
                height: 5,
              ),
              places[index].types!=null
                  ? Divider(
                      height: 1,
                    )
                  : SizedBox.shrink(),
              places[index].types!=null
                  ? Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      height: 50,
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
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10,top:10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              places[index].openNow != null
                                  ? places[index].openNow=="true"
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                  color: Color(0xffdbdbdb))),
                                          height: 30,
                                          padding:
                                              EdgeInsets.only(left: 5, right: 5),
                                          child: Row(
                                            children: [
                                              Text(AppLocalizations.of(context).detailedOpenText,
                                                  style: TextStyle(fontSize: 15,)),
                                              Text(
                                                AppLocalizations.of(context).detailedOpenStatus1,
                                                style: TextStyle(
                                                    color: Color(0xff4a6540),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              if (places[index].openingHours != null)
                                                Text(AppLocalizations.of(context).detailedClosesInText,style: TextStyle(fontSize: 15,)),
                                              if (places[index].openingHours != null)
                                                places[index].openingHours != AppLocalizations.of(context).detailedClosesInStatus1
                                                    ? Text(
                                                  places[index].openingHours
                                                      .substring(0, 2) +
                                                      ':' +
                                                      places[index].openingHours
                                                          .substring(2, 4),
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
                                            ],
                                          ),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                    shape: BoxShape.rectangle,
                                    border:
                                    Border.all(color: Color(0xffdbdbdb))),
                                height: 30,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Text(AppLocalizations.of(context).detailedOpenText,style: TextStyle(fontSize: 15,),),
                                    Text(
                                      AppLocalizations.of(context).detailedOpenStatus2,
                                      style: TextStyle(
                                          color: Color(0xffa73636),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (places[index].openingHours != null)
                                      Text(AppLocalizations.of(context).detailedOpensInText),
                                    if (places[index].openingHours != null)
                                      places[index].openingHours != AppLocalizations.of(context).detailedClosesInStatus1
                                          ? Text(
                                        places[index].openingHours
                                            .substring(0, 2) +
                                            ':' +
                                            places[index].openingHours
                                                .substring(2, 4),
                                        style: TextStyle(
                                            color: Color(0xff4a6540),
                                            fontWeight: FontWeight.bold),
                                      )
                                          : Text(
                                        places[index].openingHours,
                                        style: TextStyle(
                                            color: Color(0xff4a6540),
                                            fontWeight: FontWeight.bold),
                                      )
                                  ],
                                ),
                              )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Container(height: 2,),
                          places[index].priceLevel.isNotEmpty &&
                              places[index].priceLevel != "null"
                              ? Row(
                                children: [
                                  Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                      shape: BoxShape.rectangle,
                                      border:
                                      Border.all(color: Color(0xffdbdbdb))),
                                  height: 30,
                                  padding: EdgeInsets.all(5),
                                  child: Text(AppLocalizations.of(context).detailedPriceLevelText +
                                      transformPriceLevel(places[index]
                                          .priceLevel
                                          .characters
                                          .toString()
                                          .substring(
                                          11,
                                          places[index]
                                              .priceLevel
                                              .characters
                                              .length),context)

                                  )),
                                ],
                              )
                              : SizedBox.shrink(),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ]),
          ));
    },
    childCount: places.length,
  ));
}

String transformPriceLevel(String input, BuildContext context) {
  switch (input) {
    case "free":
      return AppLocalizations.of(context).searchFilterPriceLevel1;
      break;
    case "inexpensive":
      return AppLocalizations.of(context).searchFilterPriceLevel2;
      break;
    case "moderate":
      return AppLocalizations.of(context).searchFilterPriceLevel3;
      break;
    case "expensive":
      return AppLocalizations.of(context).searchFilterPriceLevel4;
      break;
    case "veryExpensive":
      return AppLocalizations.of(context).searchFilterPriceLevel5;
      break;
    default:
      return null;
      break;
  }
}