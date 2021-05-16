import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list_places.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        child: BlocConsumer<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial)
              return buildInitialStart();
            else if (state is HomeLoading)
              return buildLoadingState();
            else if (state is HomeLoaded)
              return buildListOfPlaces(state.places,state.googleApiKey);
            else
              return buildErrorState();
          },
          listener: (context, state) {
            if (state is HomeError) {
              Scaffold.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 1),
                  content: Text(state.error),
                ),
              );
            }
            if (state is  HomeLoaded) {
              if (state.message != null) {
                Scaffold.of(context).showSnackBar(
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
    homeBloc.add(GetUserPlaces());
    void dispose() {
      homeBloc.close();
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
            Text('Sorry your nearby places was not found!',style: TextStyle(color: Color(0xff616161),fontSize: 20),)
          ])
        ],
      ),);
  }
}