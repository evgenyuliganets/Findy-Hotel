import 'package:carousel_slider/carousel_slider.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DetailedPlace extends StatefulWidget {
 final  String placeId;
  DetailedPlace( this.placeId);
  @override
  _DetailedPlaceState createState() => _DetailedPlaceState();
}
class _DetailedPlaceState extends State<DetailedPlace> {
  var _current;

  @override
  void initState() {
    _current=0;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        child: SafeArea(
          child: BlocConsumer<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial)
                return buildInitialStart();
              else if (state is PlaceLoading)
                return buildLoadingState();
              else if (state is PlaceLoaded)
                return buildWidget(state.placesDetail,state.googleApiKey);
              else
                return buildErrorState();
            },
            listener: (context, state) {
              if (state is PlaceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(duration: const Duration(seconds: 2),
                    content: Text(state.error),
                  ),
                );
              }
              if (state is  PlaceLoaded) {
                if (state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(duration: const Duration(seconds: 2),
                      content: Text(state.message),
                      backgroundColor: Color(0xff779a76),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildWidget(PlacesDetail place, String googleApiKey) {
    return RefreshIndicator(
        onRefresh: () async {
      var lastEvent = BlocProvider.of<HomeBloc>(context).lastHomeEvent;
      return BlocProvider.of<HomeBloc>(context)
          .add(RefreshPage(event: lastEvent));
    },
    child:CustomScrollView(slivers: [
      sliverAppBar(),
      buildPlaceDetail(place, googleApiKey)
    ]));
  }
  Widget sliverAppBar(){
    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      shadowColor: Color(0xff636e86),
      backgroundColor: Color(0xff636e86),
      expandedHeight: 50,
      title: Text(AppLocalizations.of(context).detailedHeader,style: TextStyle(fontSize: 25),),
    );
  }

  Widget buildInitialStart() {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(GetDetailedPlace(widget.placeId));
    void dispose() {
      homeBloc.close();
    }
    return Center(
        child: Scaffold(
          body: LayoutBuilder(
              builder: (context, constrains) {
                return RefreshIndicator(
                    onRefresh: () async {
                      var lastEvent = BlocProvider
                          .of<HomeBloc>(context)
                          .lastHomeEvent;
                      return BlocProvider.of<HomeBloc>(context).add(
                          RefreshPage(event: lastEvent));
                    },
                    child: CustomScrollView(
                        slivers: [
                          sliverAppBar(),
                          SliverToBoxAdapter(child: Container(
                            height: constrains.maxHeight-100,
                            child: Center(
                                child: CircularProgressIndicator()),
                          )),
                        ]));
              })
        ));
  }

  Widget buildLoadingState() {
    return Center(
        child: Scaffold(
          body: LayoutBuilder(
              builder: (context, constrains) {
                return RefreshIndicator(
                  onRefresh: () async {
                    var lastEvent = BlocProvider
                        .of<HomeBloc>(context)
                        .lastHomeEvent;
                    return BlocProvider.of<HomeBloc>(context).add(
                        RefreshPage(event: lastEvent));
                  },
            child: CustomScrollView(
              slivers: [
                sliverAppBar(),
                SliverToBoxAdapter(child: Container(
                  height: constrains.maxHeight-100,
                  child: Center(
                      child: CircularProgressIndicator()),
                )),
              ]));
    })));

  }


  Widget buildErrorState() {
    return Center(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              var lastEvent = BlocProvider.of<HomeBloc>(context).lastHomeEvent;
              return BlocProvider.of<HomeBloc>(context)
                  .add(RefreshPage(event: lastEvent));
            },
            child: CustomScrollView(
              slivers: [
                sliverAppBar(),
                SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_cellular_connected_no_internet_4_bar,
                              color: Color(0xff878787),
                              size: 150,
                            ),
                            Container(
                              height: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).detailedError,
                              style: TextStyle(color: Color(0xff616161), fontSize: 20),
                            )
                          ]),
                    ))
              ],
            ),
          ),
        ));
  }


  SliverToBoxAdapter buildPlaceDetail(PlacesDetail place, String googleApiKey) {
    return SliverToBoxAdapter(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        place.photos.length!=0
            ? Column(
                children: [
                  Center(
                    child: CarouselSlider(
                      options: CarouselOptions(
                          height: 330,
                          disableCenter: false,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                      items: imageSliders(context, place.photos),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: place.photos.map((url) {
                      int index = place.photos.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            : Image.asset(
                'assets/no_image.jpg',
                height: 330,
                width: 350,
              ),
        ListTile(
          visualDensity: VisualDensity.comfortable,
          title: place.name == null
              ? SizedBox.shrink()
              : RichText(
                  text: TextSpan(
                      text: '${place.name}',
                      style: TextStyle(
                        color: Color(0xff212121),
                        fontSize: 25,
                      ))),
          subtitle: place.rating == 0 ||
                  place.rating == null ||
                  place.rating.isNaN
              ? Row(
                  children: [
                    Row(
                      children: List.generate(5, (ind) {
                        return Icon(
                          Icons.star_border,
                          color: Colors.black26,
                          size: 25,
                        );
                      }),
                    ),
                    Text(
                      AppLocalizations.of(context).detailedRatingError,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Row(
                      children: List.generate(5, (ind) {
                        return Icon(
                          ind + 1 <= place.rating
                              ? Icons.star
                              : place.rating % 1 <= 0.3 || ind > place.rating
                                  ? Icons.star_border
                                  : Icons.star_half,
                          color: Colors.amber,
                          size: 25,
                        );
                      }),
                    ),
                    Center(
                      child: Text(place.rating.toString(),
                          style: TextStyle(color: Colors.black54,fontSize: 18)),
                    ),
                  ],
                ),
        ),
        if(place.vicinity.isNotEmpty||place.formattedAddress.isNotEmpty)
        Container(
          padding: EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: place.vicinity == null
              ? RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                      style: TextStyle(color: Color(0xff5a5a5a),fontSize: 18),
                      text: place.formattedAddress))
              : RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                      style: TextStyle(color: Color(0xff5a5a5a),fontSize: 18),
                      text: place.vicinity)),
        ),
        if(place.types!=null||place.types!=null)
        Container(
          height: 5,
        ),
        place.types!=null
            ? Divider(
                height: 1,
              )
            : SizedBox.shrink(),
        place.types!=null
            ? Wrap(
            children: place.types.map((item) =>
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 2,right: 2,bottom: 0,top: 0),
                      child: FilterChip(
                              padding: EdgeInsets.only(left: 2, right: 2),
                              avatar: Image(
                                height: 30,
                                image: AssetImage('assets/$item' + '.png'),
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace stackTrace) {
                                  return Image.asset('assets/geocode.png',height: 30,);
                                },
                              ),
                              labelStyle: TextStyle(),
                              label: Text('#' + item),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              onSelected: (bool value) {}),
                    )).toList().cast<Widget>())
            : SizedBox.shrink(),
        place.openNow != null?
        Divider(
            height: 1,
          ): SizedBox.shrink(),
          Container(
            padding:
            EdgeInsets.only(left: 10, right: 10,),
            child: Column(children: [
            place.openNow != null || place.priceLevel!=null
                ? Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    place.openNow != null
                        ? place.openNow=='true'
                            ? Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Color(0xffdbdbdb))),
                                height: 30,
                                margin: EdgeInsets.only(top: 5,bottom:5),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Text(AppLocalizations.of(context).detailedOpenText,style: TextStyle(fontSize: 15,)),
                                    Text(
                                      AppLocalizations.of(context).detailedOpenStatus1,
                                      style: TextStyle(
                                          color: Color(0xff4a6540),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (place.openingHours != null)
                                      Text(AppLocalizations.of(context).detailedClosesInText,style: TextStyle(fontSize: 15,)),
                                    if (place.openingHours != null)
                                      place.openingHours != AppLocalizations.of(context).detailedClosesInStatus1
                                          ? Text(
                                              place.openingHours
                                                      .substring(0, 2) +
                                                  ':' +
                                                  place.openingHours
                                                      .substring(2, 4),
                                              style: TextStyle(
                                                  color: Color(0xffa73636),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              place.openingHours,
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
                                margin: EdgeInsets.only(top: 10,),
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
                                    if (place.openingHours != null)
                                      Text(AppLocalizations.of(context).detailedOpensInText),
                                    if (place.openingHours != null)
                                      place.openingHours != AppLocalizations.of(context).detailedClosesInStatus1
                                          ? Text(
                                              place.openingHours
                                                      .substring(0, 2) +
                                                  ':' +
                                                  place.openingHours
                                                      .substring(2, 4),
                                              style: TextStyle(
                                                  color: Color(0xff4a6540),
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              place.openingHours,
                                              style: TextStyle(
                                                  color: Color(0xff4a6540),
                                                  fontWeight: FontWeight.bold),
                                            )
                                  ],
                                ),
                              )
                        : SizedBox.shrink(),
                    place.priceLevel.isNotEmpty && place.priceLevel != "null"
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Color(0xffdbdbdb))),
                            height: 30,
                            margin: EdgeInsets.only(bottom:5),
                            padding: EdgeInsets.only(left: 5, right: 5,top:5,bottom: 5,),
                            child: Text(AppLocalizations.of(context).detailedPriceLevelText +
                                place.priceLevel.characters
                                    .toString()
                                    .substring(11,
                                        place.priceLevel.characters.length)))
                        : Container(
                          ),
                  ]),
                )
                : SizedBox.shrink(),
        if (place.formattedAddress.isNotEmpty || place.vicinity.isNotEmpty)
              Divider(
                height: 1,
              ),
            place.formattedAddress.isNotEmpty || place.vicinity.isNotEmpty
                ? Container(
                    padding: EdgeInsets.only(left: 5, top: 5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.location_city,color: Colors.blueGrey,),
                        Text(
                          AppLocalizations.of(context).detailedAddressText,
                          style: TextStyle(fontSize: 17,color: Color(0xff5a5a5a)),
                        ),
                      ],
                    ))
                : SizedBox.shrink(),
            if (place.vicinity.isNotEmpty || place.formattedAddress.isNotEmpty)
              Container(
                padding: EdgeInsets.only(left: 10, bottom: 5),
                alignment: Alignment.centerLeft,
                child: place.formattedAddress.isNotEmpty
                    ? RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                            style:
                                TextStyle(color: Color(0xff212121), fontSize: 15),
                            text: place.formattedAddress))
                    : RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                            style:
                                TextStyle(color: Color(0xff212121), fontSize: 15),
                            text: place.vicinity)),
              ),
            if (place.internationalPhoneNumber != null ||
                place.formattedPhoneNumber != null)
              Divider(
                height: 1,
              ),
            place.internationalPhoneNumber != null ||
                    place.formattedPhoneNumber != null
                ? Container(
                    padding: EdgeInsets.only(left: 5, top: 5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.phone,color: Colors.green,),
                        Text(
                          AppLocalizations.of(context).detailedPhoneText,
                          style: TextStyle(fontSize: 15,color: Color(0xff5a5a5a)),
                        ),
                      ],
                    ))
                : SizedBox.shrink(),
            if (place.internationalPhoneNumber != null ||
                place.formattedPhoneNumber != null)
              Container(
                  padding: EdgeInsets.only(left: 10, bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: place.internationalPhoneNumber != null
                      ? GestureDetector(
                          child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Color(0xff212121), fontSize: 15),
                                  text: place.internationalPhoneNumber)),
                          onLongPress: () {
                            Clipboard.setData(new ClipboardData(
                                text: place.internationalPhoneNumber));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(
                              content: new Text(AppLocalizations.of(context).detailedCopiedToClipboard),
                              duration: Duration(seconds: 2),
                            ));
                          },
                        )
                      : GestureDetector(
                          child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Color(0xff212121), fontSize: 15),
                                  text: place.formattedPhoneNumber)),
                          onLongPress: () {
                            Clipboard.setData(new ClipboardData(
                                text: place.formattedPhoneNumber));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(
                              content: new Text(AppLocalizations.of(context).detailedCopiedToClipboard),
                              duration: Duration(seconds: 2),
                            ));
                          },
                        )),
            if (place.website!=null)
              Divider(
                height: 1,
              ),
            place.website!=null
                ? Container(
                    padding: EdgeInsets.only(left: 5, top: 5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.web_sharp,color: Colors.blueAccent,),
                        Text(
                          AppLocalizations.of(context).detailedWebsiteText,
                          style: TextStyle(fontSize: 17,color: Color(0xff5a5a5a)),
                        ),
                      ],
                    ))
                : SizedBox.shrink(),
            if (place.website!=null)
              Container(
                  padding: EdgeInsets.only(left: 10, bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                          child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Color(0xff0354fa), fontSize: 15),
                                  text: place.website)),
                          onTap: () {
                            launch(place.website);
                          },
                        )
              ),
        if (place.utcOffset != null)
            Divider(
              height: 1,
            ),
        place.utcOffset != null
              ? Container(
              padding: EdgeInsets.only(left: 5, top: 5),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.av_timer,color: Colors.deepPurple,),
                  Text(
                    AppLocalizations.of(context).detailedUtcText,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ))
              : SizedBox.shrink(),
        if (place.utcOffset != null)
            Container(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              alignment: Alignment.centerLeft,
              child:  RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                      style: TextStyle(
                          color: Color(0xff5a5a5a), fontSize: 15),
                      text: (place.utcOffset<0?"":"+")+(place.utcOffset/60).round().toString()+AppLocalizations.of(context).detailedHoursUtsText)),

            ),
              if (place.longitude != null)
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10,right: 5,left: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Color(0x70A5A5A5)),
                    borderRadius: BorderRadius.all(Radius.circular(10),),
                    color: Color(0x70d9e0f0),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:
                        EdgeInsets.only( bottom: 5, top: 5),
                        child: Row(
                          children: [
                            Icon(Icons.map,color: Color(0xff3c5336),),
                            Text(
                              AppLocalizations.of(context).detailedOnMap,
                              style: TextStyle(fontSize: 17,color: Color(0xff5a5a5a)),
                            ),
                          ],
                        ),
                      ),
                      buildMap(place),
                    ],
                  ),
                )

    ]),
          )],
      ),
    );
  }

  List<Widget> imageSliders(BuildContext context, List<ImageProvider> imgList) {
    TransformationController controllerT = TransformationController();
    var initialControllerValue;
    return imgList
        .map((item) => Center(
              child: Container(
                height: 500,
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          barrierDismissible: true,
                          barrierColor: Color(0x75393939),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  boundaryMargin: EdgeInsets.all(150),
                                  transformationController: controllerT,
                                  onInteractionStart: (details){
                                    initialControllerValue = controllerT.value;
                                  },
                                  onInteractionEnd: (details){
                                    controllerT.value = initialControllerValue;
                                  },
                                  minScale: 0.5,
                                  maxScale: 3,
                                  child: Image(
                                    image: item,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                          color: Colors.black12,
                                          height: 250,
                                          width: 350,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.black26),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Image(
                        image: item,
                        fit: BoxFit.cover,
                        height: 500,
                        width: 500,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              color: Colors.black12,
                              height: 500,
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
                      ),
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }
  Widget buildMap(PlacesDetail place) {
    var markers = List<Marker>();
    markers.add(Marker(markerId: MarkerId('1'),
        position: LatLng(place.latitude ?? 0, place.longitude ?? 0),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.formattedAddress ?? place.vicinity,
        )));
        return Container(
                height: 400,
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: Set<Marker>.of(markers),
                  initialCameraPosition: CameraPosition(
                      target: LatLng(markers.first.position.latitude,
                          markers.first.position.longitude),
                      zoom: 14),
                ),
              );
  }

}