import 'package:find_hotel/bottom_navigation/bloc/bottom_navigation_bloc.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/data_repository/home_repository.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/view/home_page.dart';
import 'package:find_hotel/main.dart';
import 'package:find_hotel/map/map_page.dart';
import 'package:find_hotel/map/repository/map_repository.dart';
import 'package:find_hotel/profile/profile_page.dart';
import 'package:find_hotel/profile/repository/profile_repository.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';



class MainNavbar extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => MainNavbar());
  }
  @override
  Widget build(BuildContext context) {
   return BlocProvider<BottomNavigationBloc>(
      create: (context) => BottomNavigationBloc(
          homeRepository: HomeDataRepository(),
          mapRepository: MapRepository(),
          profileRepository: ProfileRepository())..add(AppStarted()),
      child:Scaffold(
        body: BlocConsumer<BottomNavigationBloc, BottomNavigationState>(
          builder: (BuildContext context, BottomNavigationState state) {
          if (state is PageLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is HomePageStarted) {
            return Scaffold(
              body: BlocProvider(
                create: (context) => HomeBloc(HomeDataRepository()),
                child: HomePage(),
              ),

            );
          }
          if (state is MapPageLoaded) {
            return MapPage(number: state.number);
          }
          if (state is ProfilePageLoaded) {
            return ProfilePage(number: state.number);
          }
          return Container();
          },
          listener: (context, state) {
            if (state is PageError) {
              Scaffold.of(context).showSnackBar(
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
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.black87),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map, color: Colors.black87),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.black87),
                  label: 'Profile',
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