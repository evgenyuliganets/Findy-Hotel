import 'package:find_hotel/bottom_navigation/bloc/bottom_navigation_bloc.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart' as Home;
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/home/view/detail_place_page.dart';
import 'package:find_hotel/map/bloc/map_bloc.dart';
import 'package:find_hotel/map/view/map_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> {
  bool checkSearchMode;
  @override
  void initState() {
    super.initState();
    checkSearchMode=false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: BlocConsumer<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapInitial)
              return buildInitialStart(state.googleApiKey,state.textFieldText);
            else if (state is MapLoading)
              return buildLoadingState(state.googleApiKey,state.textFieldText);
            else if (state is MapLoaded)
              return buildWidget(state.textFieldText,state.googleApiKey, context,state.places);
            else if (state is MapError)
              return buildErrorState(apiKey:state.apiKey,textFieldText: state.textFieldText);
            else return null;
          },
          listener: (context, state) {
            if (state is MapError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 2),
                  content: Text(state.error),
                ),
              );
            }
            if (state is  MapLoaded) {
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
        ));
  }

  Widget buildWidget(String textFieldText, String googleApiKey,
      BuildContext context, List<PlacesDetail> places) {
    print(3);
    var markers = List<Marker>.empty(growable: true);
    var j = 0;
    print(places.toString());
    if (places.first.latitude != null) markers.length = places.length;
    places.forEach((places) {
      markers[j] = Marker(
          markerId: MarkerId(j.toString()),
          position: LatLng(places.latitude ?? 0, places.longitude ?? 0),
          infoWindow: InfoWindow(
              title: places.name,
              snippet: places.formattedAddress ?? places.vicinity,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => Home.HomeBloc(HomeDataRepository(context)),
                      child: DetailedPlace(places.placeId),
                    ),
                  ),
                );
              }));
      j++;
    });
    return LayoutBuilder(
      builder: (context, constrains) {
        final mapBloc = context.read<MapBloc>();
        final homeBloc = context.read<Home.HomeBloc>();
        final navBloc= context.read<BottomNavigationBloc>();
        var lastEvent = BlocProvider.of<MapBloc>(context).lastMapEvent;
        return CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              searchSliverAppBar(googleApiKey, context,
                  textFieldText: textFieldText),
              SliverToBoxAdapter(
                  child: Container(
                    height: constrains.maxHeight - 100,
                    child: Stack(
                      children: [
                        GoogleMap(
                              onTap: (LatLng point) {
                                print(point.toString() + " Map Clicked");
                                final mapBloc = context.read<MapBloc>();
                                var finalFilters = mapBloc.getFilterModel();
                                mapBloc.add(GetPlacesOnMap(
                                    latlng: point,
                                    mainSearchMode: checkSearchMode,
                                    filters: finalFilters ?? SearchFilterModel()));
                                  mapBloc.close();
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              markers: Set<Marker>.of(markers),
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(markers.first.position.latitude,
                                      markers.first.position.longitude),
                                  zoom: markers.length > 20
                                      ? 5
                                      : markers.length >= 10
                                          ? 12
                                          : markers.length >= 5
                                              ? 13
                                              : markers.length < 5
                                                  ? 14
                                                  : null),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: OutlinedButton(
                                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Color(
                                    0xbcffffff))),
                                onPressed: (){
                                  var finalFilters = mapBloc.getFilterModel();
                                  var filters= finalFilters??SearchFilterModel();
                                  homeBloc.setFiltersParameters(finalFilters??SearchFilterModel());
                                if(lastEvent is GetPlacesOnMap){
                                  homeBloc.add(Home.GetPlaces(latlng: lastEvent.latlng,
                                      textFieldText: lastEvent.textFieldText,filters: filters,
                                      mainSearchMode: lastEvent.mainSearchMode));
                                  navBloc.add(PageTapped(index: 0));
                                }
                                if(lastEvent is GetMapUserPlaces){
                                  homeBloc.add(Home.GetUserPlaces(filters: lastEvent.filters,
                                      mainSearchMode: lastEvent.mainSearchMode));
                                  navBloc.add(PageTapped(index: 0));
                                }
                              },
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back_rounded, color: Color(
                                        0xff475172),),
                                    Text(AppLocalizations.of(context).mapResultsOnList,
                                      style: TextStyle(color: Colors.black87),),
                                  ],
                                ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ]);
      },
    );
  }

  Widget buildInitialStart(googleApiKey, textFieldText) {
    print(1);
    final mapBloc = context.read<MapBloc>();
    print("this");
    mapBloc.add(GetMapUserPlaces(mainSearchMode: true));

    return LayoutBuilder(
        builder: (context, constrains) {
          return CustomScrollView(
              slivers: [
                searchSliverAppBar(
                    googleApiKey, context, textFieldText: textFieldText),
                SliverToBoxAdapter(child: Container(
                  height: constrains.maxHeight-100,
                  child: Center(
                      child: CircularProgressIndicator()),
                )),
              ]);
        });
  }

  Widget buildLoadingState(googleApiKey, textFieldText) {
    print(2);
    return LayoutBuilder(
        builder: (context, constrains) {
          return CustomScrollView(
              slivers: [
                searchSliverAppBar(
                    googleApiKey, context, textFieldText: textFieldText),
                SliverToBoxAdapter(child: Container(
                  height: constrains.maxHeight-100,
                  child: Center(
                      child: CircularProgressIndicator()),
                )),
              ]);
        });
  }

  Widget buildErrorState({String apiKey, String textFieldText}) {
    print(4);
    return Center(
        child: Scaffold(
          body:LayoutBuilder(
        builder: (context, constrains) {
      return RefreshIndicator(
            onRefresh: () async {
              var lastEvent = BlocProvider.of<MapBloc>(context).lastMapEvent;
              return BlocProvider.of<MapBloc>(context)
                  .add(RefreshPage(event: lastEvent));
            },
            child: CustomScrollView(
              slivers: [
                searchSliverAppBar(apiKey, context, textFieldText: textFieldText),
                SliverToBoxAdapter(
                    child: Container(
                      height: constrains.maxHeight-100,
                      child: GoogleMap(
                        onTap: (LatLng point) {
                          print(point.toString()+"Map Clicked");
                          final mapBloc = context.read<MapBloc>();
                          var finalFilters = mapBloc.getFilterModel();
                          mapBloc.add(GetPlacesOnMap(latlng: point,mainSearchMode: checkSearchMode,filters:finalFilters??SearchFilterModel()));
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        initialCameraPosition: CameraPosition(target: LatLng(0,0)),
                      ),
                    )),
              ],
            ),
          );},
    ))
    );
  }
  Widget searchSliverAppBar(String googleApiKey,BuildContext context,{String textFieldText}){
    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      shadowColor: Color(0xff9baed5),
      backgroundColor: Color(0xff9baed5),
      expandedHeight: 100,
      title: MapTextField(
        googleApiKey,
        textFieldText: textFieldText,
        checkMainSearchMode: checkSearchMode,
      ),
      flexibleSpace: Container(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.only(right: 20,left: 20,bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(AppLocalizations.of(context).homeByPlace),
              Container(
                height: 37,
                width:60,
                child: Switch(
                    activeColor: Color(0xff636e86),
                    value: checkSearchMode,
                    onChanged: (bool value) {
                      setState(() {
                        checkSearchMode=value;
                      });
                    }),
              ),
              Text(AppLocalizations.of(context).homeByName),
              Spacer(),
              Ink(
                  height: 38,
                  width: 38,
                  decoration: const ShapeDecoration(
                    color: Color(0xff636e86),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      var lastEvent = BlocProvider.of<MapBloc>(context).lastMapEvent;
                      return BlocProvider.of<MapBloc>(context).add(RefreshPage(event: lastEvent));
                    },
                    icon: Icon(
                      Icons.refresh_sharp,
                      color: Color(0xffd2d2d2),
                    ),
                    iconSize: 22,
                    color: Colors.blueGrey,
                  )),
              SizedBox(width: 5,),
              Ink(
                  height: 38,
                  width: 38,
                  decoration: const ShapeDecoration(
                    color: Color(0xff636e86),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final homeBloc = context.read<MapBloc>();
                      homeBloc.add(GetMapUserPlaces(mainSearchMode: checkSearchMode));
                    },
                    icon: Icon(
                      Icons.location_on_outlined,
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


}