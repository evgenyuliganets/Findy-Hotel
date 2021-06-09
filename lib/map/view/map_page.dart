import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/view/text_field.dart';
import 'package:find_hotel/map/bloc/map_bloc.dart';
import 'package:find_hotel/map/view/build_map_of_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        body: SafeArea( child:BlocConsumer<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapInitial)
              return buildInitialStart();
            else if (state is MapLoading)
              return buildLoadingState();
            else if (state is MapLoaded)
              return buildWidget(state.textFieldText,state.places,state.googleApiKey, context);
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

  Widget buildWidget(String textFieldText, List<PlacesDetail> places, String googleApiKey,BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        var lastEvent = BlocProvider.of<MapBloc>(context).lastMapEvent;
        return BlocProvider.of<MapBloc>(context).add(RefreshPage(event: lastEvent));
      },
      child: CustomScrollView(
          slivers: [
            searchSliverAppBar(googleApiKey,context,textFieldText: textFieldText),
            buildMapListOfPlaces(textFieldText, places, googleApiKey, context)
          ]),
    );
  }

  Widget buildInitialStart() {
    final mapBloc = context.read<MapBloc>();
    mapBloc.add(GetMapUserPlaces(mainSearchMode: true));
    void dispose() {
      mapBloc.close();
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorState({String apiKey, String textFieldText}) {
    return Center(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              var lastEvent = BlocProvider.of<MapBloc>(context).lastMapEvent;
              return BlocProvider.of<MapBloc>(context)
                  .add(RefreshPage(event: lastEvent));
            },
            child: CustomScrollView(
              slivers: [
                searchSliverAppBar(apiKey, context, textFieldText: textFieldText),
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
                              'Sorry, your places was not found!',
                              style: TextStyle(color: Color(0xff616161), fontSize: 20),
                            )
                          ]),
                    ))
              ],
            ),
          ),
        ));
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
      title: HomeTextField(
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
              Text('Search by Place'),
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
              Text('Search by Name'),
              Spacer(),
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