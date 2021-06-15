import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/view/build_list_of_places.dart';
import 'package:find_hotel/home/view/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
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
        child:BlocConsumer<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial)
            return buildInitialStart(state.googleApiKey,state.textFieldText);
          else if (state is HomeLoading)
            return buildLoadingState(state.googleApiKey,state.textFieldText,);
          else if (state is HomeLoaded)
            return buildWidget(state.textFieldText,state.places,state.googleApiKey, context);
          else if (state is HomeError)
            return buildErrorState(apiKey:state.apiKey,textFieldText: state.textFieldText);
          else return null;
        },
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(duration: const Duration(milliseconds: 2500),
                content: Text(state.error),
              ),
            );
          }
          if (state is  HomeLoaded) {
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
         var lastEvent = BlocProvider.of<HomeBloc>(context).lastHomeEvent;
       return BlocProvider.of<HomeBloc>(context).add(RefreshPage(event: lastEvent));
       },
       child: CustomScrollView(
           slivers: [
         searchSliverAppBar(googleApiKey,context,textFieldText: textFieldText),
         buildListOfPlaces(textFieldText, places, googleApiKey, context)
       ]),
     );
  }

  Widget buildInitialStart(googleApiKey, textFieldText) {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(GetUserPlaces(mainSearchMode: true));
    return LayoutBuilder(
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
                    searchSliverAppBar(
                        googleApiKey, context, textFieldText: textFieldText),
                    SliverToBoxAdapter(child: Container(
                      height: constrains.maxHeight-100,
                      child: Center(
                          child: CircularProgressIndicator()),
                    )),
                  ]));
        });
  }

  Widget buildLoadingState(googleApiKey, textFieldText) {
    return LayoutBuilder(
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
                    searchSliverAppBar(
                        googleApiKey, context, textFieldText: textFieldText),
                    SliverToBoxAdapter(child: Container(
                      height: constrains.maxHeight-100,
                      child: Center(
                          child: CircularProgressIndicator()),
                    )),
                  ]));
        });
  }

  Widget buildErrorState({String apiKey, String textFieldText}) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrains)
    {
      return RefreshIndicator(
        onRefresh: () async {
          var lastEvent = BlocProvider
              .of<HomeBloc>(context)
              .lastHomeEvent;
          return BlocProvider.of<HomeBloc>(context)
              .add(RefreshPage(event: lastEvent));
        },
        child: CustomScrollView(
          slivers: [
            searchSliverAppBar(apiKey, context, textFieldText: textFieldText),
            SliverToBoxAdapter(
                child: Container(
                  height: constrains.maxHeight-200,
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
                            style: TextStyle(
                                color: Color(0xff616161), fontSize: 20),
                          )
                        ]),
                  ),
                ))
          ],
        ),
      );
    }));
  }
  Widget searchSliverAppBar(String googleApiKey,BuildContext context,{String textFieldText}){
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
                      final homeBloc = context.read<HomeBloc>();
                      homeBloc.add(GetUserPlaces());
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