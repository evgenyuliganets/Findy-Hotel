import 'package:find_hotel/authentication/bloc/authentication_bloc.dart';
import 'package:find_hotel/database/authentication/users_repository.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/login/view/login_page.dart';
import 'package:find_hotel/profile/bloc/profile_bloc.dart';
import 'package:find_hotel/profile/view/user_places_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}
final _userRepository = UsersRepository();
class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileInitial)
              return buildInitialStart();
            else if (state is ProfileLoading)
              return buildLoadingState();
            else if (state is ProfileLoaded)
              return buildProfilePage(state.places, state.username);
            else
              return buildErrorState();
          },
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 1),
                  content: Text(state.error),
                ),
              );
            }
            if (state is ProfileLoaded) {
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
    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(GetUserPlaces());
    void dispose() {
      profileBloc.close();
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildGreeting(String user)  {
      return Container(
       child:user!=null? Text('Welcome, $user!',style: TextStyle(fontSize: 25,fontFamily: 'Times New Roman'),):Text('UnknownUser')
    );
  }


  Widget buildProfilePage(List<PlacesDetail> list, String user) {
    return ListView(
      shrinkWrap: true,
      children: [
          buildGreeting(user),
          buildLogout(),
          buildUserProfilePlaces(list),
        ],
    );
  }
  Widget buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildLogout(){
    return  OutlinedButton(
      child: const Text('Logout'),
      onPressed: () {
        _showDialog();
      },
    );
  }
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Logout"),
          content: new Text("You sure you want to logout? All local data will be erased!"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
                _userRepository.deleteAllUsers();
                Navigator.pushAndRemoveUntil<void>(context,
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
    return Center(
      child: Column(
        children: [
          Container(height: 30,),
          Column(children: [
            Icon(Icons.signal_cellular_connected_no_internet_4_bar,
              color: Color(0xff878787),
              size: 150,),
            Container(height: 10,),
            Text('Sorry your nearby places was not found!',
              style: TextStyle(color: Color(0xff616161), fontSize: 20),)
          ])
        ],
      ),);
  }
}