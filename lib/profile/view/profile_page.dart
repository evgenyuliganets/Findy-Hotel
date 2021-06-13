import 'package:find_hotel/authentication/bloc/authentication_bloc.dart';
import 'package:find_hotel/database/authentication/users_repository.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/login/view/login_page.dart';
import 'package:find_hotel/profile/bloc/profile_bloc.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'build_profile_list_of_places.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

final _userRepository = UsersRepository();
final _placeRepository = PlacesRepository();
final _photoRepository = PlacesRepository();
ProfileRepository profileRepo;

class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: LayoutBuilder(builder: (context, constrains) {
      return RefreshIndicator(
          onRefresh: () async {},
          child: CustomScrollView(slivers: [
            sliverAppBar(),
            SliverToBoxAdapter(
                child: Container(
              color: Color(0xffb8c4de),
              child: Row(
                children: [buildGreeting(), Spacer(), buildLogout()],
              ),
            )),
            SliverToBoxAdapter(
              child: Container(
                 child: Text('Recently Viewed Places',style: TextStyle(fontSize: 20),),
            ),),
            SliverToBoxAdapter(
              child: Container(
                  height: 480, child: buildBlocList('Recently Viewed Places')),
            ),
          SliverToBoxAdapter(
              child: Container(
                child: Text('Favorite Places',style: TextStyle(fontSize: 20),),
              ),),
            SliverToBoxAdapter(
              child: Container(
                  height: 480, child: buildBlocList('Favorite Places')),
            )
          ]));
    })));
  }

  Widget sliverAppBar() {
    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      shadowColor: Color(0xff636e86),
      backgroundColor: Color(0xff636e86),
      expandedHeight: 50,
      titleSpacing: 20,
      title: Text(
        'Profile',
        style: TextStyle(fontSize: 25),
      ),
    );
  }

  Widget buildInitialStart() {
    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(GetRecentlyViewedPlaces());
    void dispose() {
      profileBloc.close();
    }

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildBlocList(String listToBuild) {
    final profileBloc = context.read<ProfileBloc>();
    if (listToBuild == 'Recently Viewed Places') {
      print(true);
      profileBloc.add(GetRecentlyViewedPlaces());
    } else {
      print(false);
      profileBloc.add(GetFavoritePlaces());
    }
    return Container(
      padding: EdgeInsets.only(left: 20),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading)
            return buildLoadingState();
          else if (state is ProfileLoaded)
            return buildList(state.places);
          else if (state is ProfileError)
            return buildErrorState();
          else
            return buildLoadingState();
        },
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(state.error),
              ),
            );
          }
          if (state is ProfileLoaded) {
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(state.message),
                  backgroundColor: Color(0xff779a76),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget buildGreeting() {
    return Container(
        padding: EdgeInsets.only(left: 20),
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  child: Text(
                '${AppLocalizations.of(context).headerProfile} ${snapshot.data}!',
                style: TextStyle(
                  fontSize: 25,
                ),
              ));
            }
            if (snapshot.hasError) {
              return Container(
                  child: Text(
                '${AppLocalizations.of(context).headerProfile} ${snapshot.error}!',
                style: TextStyle(
                  fontSize: 25,
                ),
              ));
            } else {
              return CircularProgressIndicator();
            }
          },
          future: _userRepository
              .getAllUser()
              .then((value) => value.first.username.toString()),
        ));
  }

  Widget buildList(List<PlacesDetail> places) {
    return Container(height: 480, child: buildProfileListOfPlaces(places));
  }

  Widget buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildLogout() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: OutlinedButton(
        child: Text(AppLocalizations.of(context).logout),
        onPressed: () {
          _showDialog();
        },
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).logout),
          content: new Text(AppLocalizations.of(context).warningProfile),
          actions: <Widget>[
            new TextButton(
              child: new Text(AppLocalizations.of(context).cancelButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text(AppLocalizations.of(context).logout),
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
                _userRepository.deleteAllUsers();
                _placeRepository.deleteAllPlaces();
                _photoRepository.deleteAllPlaces();
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  LoginPage.route(),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildErrorState() {
    return Container(
        child: Center(
      child: Column(
        children: [
          Container(
            height: 30,
          ),
          Column(children: [
            Icon(
              Icons.signal_cellular_connected_no_internet_4_bar,
              color: Color(0xff878787),
              size: 150,
            ),
            Container(
              height: 10,
            ),
            Text(
              AppLocalizations.of(context).profileError,
              style: TextStyle(color: Color(0xff616161), fontSize: 20),
            )
          ])
        ],
      ),
    ));
  }
}
