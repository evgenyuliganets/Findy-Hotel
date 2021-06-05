import 'package:find_hotel/bottom_navigation/bloc/bottom_navigation_bloc.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/view/home_page.dart';
import 'package:find_hotel/map/map_page.dart';
import 'package:find_hotel/map/repository/map_repository.dart';
import 'package:find_hotel/profile/bloc/profile_bloc.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:find_hotel/profile/view/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class MainNavbar extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => MainNavbar());
  }
  @override
  Widget build(BuildContext context) {
   return MultiBlocProvider(providers:[
     BlocProvider<BottomNavigationBloc>(
      create: (context) => BottomNavigationBloc(
          mapRepository: MapRepository(),)..add(AppStarted()),),
     BlocProvider(
       create: (context) => HomeBloc(HomeDataRepository()),
     ),
     BlocProvider(
       create: (context) => ProfileBloc(ProfileRepository()),
     ),
   ],
      child:Scaffold(
        body: BlocConsumer<BottomNavigationBloc, BottomNavigationState>(
          builder: (BuildContext context, BottomNavigationState state) {
          if (state is PageLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is HomePageStarted) {
            return Scaffold(
              body: HomePage(),
              );
          }
          if (state is MapPageStarted) {
            return MapPage(number: state.number);
          }
          if (state is ProfilePageStarted) {
            return Scaffold(
              body: ProfilePage(),
            );
          }
          return Container();
          },
          listener: (context, state) {
            if (state is PageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 1),
                  content: Text(state.error),
                ),
              );
            }
          },
      ),
      bottomNavigationBar:
      BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
          builder: (BuildContext context, BottomNavigationState state) {
            return BottomNavigationBar(
              currentIndex:
              context.select((BottomNavigationBloc bloc) => bloc.currentIndex),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.black87),
                  label: AppLocalizations.of(context).homeTab,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map, color: Colors.black87),
                  label: AppLocalizations.of(context).mapTab,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.black87),
                  label: AppLocalizations.of(context).profileTab,
                ),
              ],
              onTap: (index) => context
                  .read<BottomNavigationBloc>()
                  .add(PageTapped(index: index)),
            );
          }),
      )
    );
  }
}