import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/view/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailedPlace extends StatefulWidget {
 final  String placeId;
  DetailedPlace( this.placeId);
  @override
  _DetailedPlaceState createState() => _DetailedPlaceState();
}
class _DetailedPlaceState extends State<DetailedPlace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        child: BlocConsumer<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial)
              return buildInitialStart();
            else if (state is PlaceLoading)
              return buildLoadingState();
            else if (state is PlaceLoaded)
              return buildPlaceDetail(state.placesDetail,state.googleApiKey);
            else
              return buildErrorState();
          },
          listener: (context, state) {
            if (state is PlaceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 1),
                  content: Text(state.error),
                ),
              );
            }
            if (state is  PlaceLoaded) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(duration: const Duration(seconds: 1),
                    content: Text(state.message),
                    backgroundColor: Color(0xff779a76),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildInitialStart() {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(GetDetailedPlace(widget.placeId));
    void dispose() {
      homeBloc.close();
    }
    return buildLoadingState();
  }

  Widget buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }


  Widget buildErrorState() {
    return Center(
      child: Column(
        children:[
          Container(height: 30,),
          Column(children:[
            Icon(Icons.signal_cellular_connected_no_internet_4_bar,
              color: Color(0xff878787),
              size: 150,),
            Container(height: 10,),
            Text('Sorry this Place was not found!',style: TextStyle(color: Color(0xff616161),fontSize: 20),)
          ])
        ],
      ),
    );
  }
}