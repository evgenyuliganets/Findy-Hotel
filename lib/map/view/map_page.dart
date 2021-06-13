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
                      create: (context) => Home.HomeBloc(HomeDataRepository()),
                      child: DetailedPlace(places.placeId),
                    ),
                  ),
                );
              }));
      print(markers[j].position);
      j++;
    });
    return LayoutBuilder(
      builder: (context, constrains) {
        return CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              searchSliverAppBar(googleApiKey, context,
                  textFieldText: textFieldText),
              SliverToBoxAdapter(
                  child: Container(
                height: constrains.maxHeight - 100,
                child: GoogleMap(
                  onTap: (LatLng point) {
                    print(point.toString() + " Map Clicked");
                    final mapBloc = context.read<MapBloc>();
                    var finalFilters = mapBloc.getFilterModel();
                    mapBloc.add(GetPlacesOnMap(
                        latlng: point,
                        mainSearchMode: checkSearchMode,
                        filters: finalFilters ?? SearchFilterModel()));
                    void dispose() {
                      mapBloc.close();
                    }
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
              )),
            ]);
      },
    );
  }

  Widget buildInitialStart(googleApiKey, textFieldText) {
    final mapBloc = context.read<MapBloc>();
    print("this");
    mapBloc.add(GetMapUserPlaces(mainSearchMode: true));
    void dispose() {
      mapBloc.close();
    }
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
                          void dispose() {
                            mapBloc.close();
                          }
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
    print("searchMode:"+checkSearchMode.toString());
    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      shadowColor: Color(0xff9baed5),
      backgroundColor: Color(0xff9baed5),
      expandedHeight: 100,
      title: Wrap(
        children: [
          MapTextField(
            googleApiKey,
            textFieldText: textFieldText,
            checkMainSearchMode: checkSearchMode,
          ),
        ],
      ),
      flexibleSpace: Container(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.only(right: 20,left: 20,bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('By Place'),
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
              Text('By Name'),
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
                      homeBloc.add(GetMapUserPlaces());
                      void dispose() {
                        homeBloc.close();
                      }
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