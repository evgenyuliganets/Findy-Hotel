import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/view/text_field.dart';
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
      body: SafeArea( child:Container(
        height: 800,
        child: BlocConsumer<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial)
              return buildInitialStart();
            else if (state is HomeLoading)
              return buildLoadingState();
            else if (state is HomeLoaded)
              return buildListOfPlaces(state.textFieldText,state.places,state.googleApiKey, context);
            else if (state is HomeError)
              return buildErrorState(apiKey:state.apiKey);
            else return null;
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
    ));
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



  Widget buildErrorState({String apiKey}) {
    return Center(
      child: Scaffold(
        body: Column(
          children:[
            HomeTextField(apiKey),
            Container(height: 30,),
            Column(children:[
              Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                color: Color(0xff878787),
                size: 150,),
              Container(height: 10,),
              Text('Sorry your nearby places was not found!',style: TextStyle(color: Color(0xff616161),fontSize: 20),)
            ])
          ],
        ),
      ),);
  }
}