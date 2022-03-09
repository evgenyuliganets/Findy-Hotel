import 'package:find_hotel/authentication/bloc/authentication_bloc.dart';
import 'package:find_hotel/database/authentication/users_repository.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/login/view/login_page.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:find_hotel/profile/favorite_bloc/favorite_bloc.dart';
import 'package:find_hotel/profile/recently_viewed_bloc/recently_viewed_bloc.dart';
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
        body: Container(child:
        LayoutBuilder(builder: (context, constrains) {
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
            FavoriteBloc(ProfileRepository(context)).add(GetFavoritePlaces());
            RecentlyViewedBloc(ProfileRepository(context)).add(GetRecentlyViewedPlaces());
          });
          },
          child: CustomScrollView(slivers: [
            sliverAppBar(),
            SliverToBoxAdapter(
                child: Container(
              color: Color(0xffeaedef),
              child: Row(
                children: [buildGreeting(), Spacer(), buildLogout()],
              ),
            )),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10,right: 5,left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0x70A5A5A5)),
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                  color: Color(0x70d9e0f0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 5),
                      child: Text(
                        AppLocalizations.of(context).recentHeader,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                 buildRecentlyViewed(AppLocalizations.of(context).recentHeader),
                  ],
                ),
              ),),
          SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10,right: 5,left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0x70A5A5A5)),
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                  color: Color(0x70d9e0f0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 5),
                      child: Text(
                        AppLocalizations.of(context).favoriteHeader,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    buildFavorite(AppLocalizations.of(context).favoriteHeader),
                  ],
                ),
              ),
          ),
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
        AppLocalizations.of(context).profileTab,
        style: TextStyle(fontSize: 25),
      ),
    );
  }

  Widget buildRecentlyViewed(String listToBuild) {
    final recentBloc = context.read<RecentlyViewedBloc>();
       recentBloc.add(GetRecentlyViewedPlaces());
      return Container(
        padding: EdgeInsets.only(left: 2,top:5),
        child: BlocConsumer<RecentlyViewedBloc, RecentlyViewedState>(
          builder: (context, state) {
            if (state is RecentlyViewedLoading)
              return buildLoadingState();
            else if (state is RecentlyViewedLoaded)
              return buildList(state.places);
            else if (state is RecentlyViewedError)
              return buildRecentErrorState(listToBuild);
            else
              return buildLoadingState();
          },
          listener: (context, state) {
            if (state is RecentlyViewedError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(state.error),
                ),
              );
            }
            if (state is RecentlyViewedLoaded) {
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

  Widget buildFavorite(String listToBuild) {
    final profileBloc = context.read<FavoriteBloc>();
      profileBloc.add(GetFavoritePlaces());
    return Container(
      padding: EdgeInsets.only(left: 2,top:5),
      child: BlocConsumer<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading)
            return buildLoadingState();
          else if (state is FavoriteLoaded)
            return buildList(state.places);
          else if (state is FavoriteError)
            return buildFavoriteErrorState(listToBuild);
          else
            return buildLoadingState();
        },
        listener: (context, state) {
          if (state is FavoriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(state.error),
              ),
            );
          }
          if (state is FavoriteLoaded) {
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
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 200, horizontal: 20),
          child: CircularProgressIndicator()),
    );
  }

  Widget buildLogout() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: OutlinedButton(
        child: Text(AppLocalizations.of(context).logout,style: TextStyle(color: Colors.black87),),
        style: ButtonStyle(),
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

  Widget buildRecentErrorState(text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: Center(
      child: Column(
        children: [
          Container(
            height: 30,
          ),
          Column(children: [
            Icon(
              Icons.speaker_notes_off_outlined,
              color: Color(0xff878787),
              size: 150,
            ),
            Container(
              height: 10,
            ),
            Text(AppLocalizations.of(context).recentHeaderError,
                style: TextStyle(color: Color(0xff616161), fontSize: 20),
            )
          ])
        ],
      ),
    ));
  }
  Widget buildFavoriteErrorState(text) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Container(
                height: 30,
              ),
              Column(children: [
                Icon(
                  Icons.favorite_border,
                  color: Color(0xff878787),
                  size: 150,
                ),
                Container(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).favErrorHeader,
                  style: TextStyle(color: Color(0xff616161), fontSize: 20),
                )
              ])
            ],
          ),
        ));
  }
}
