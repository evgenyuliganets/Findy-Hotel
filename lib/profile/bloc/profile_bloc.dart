import 'dart:async';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileEvent lastProfileEvent;
  final ProfileRepository profileRepo;
  final PlacesNotFoundException error;
  ProfileBloc(this.profileRepo, {this.error}) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
      ProfileEvent event,
      ) async* {
    lastProfileEvent=event;

    if (event is RefreshPage){
      this.add(event.event);
    }

    if (event is GetFavoritePlaces) {           //Get Favorite Places or Places from dataBase
      try {
        yield (ProfileLoading());
        final places = await profileRepo.fetchFavoritePlacesFromDataBase().timeout(Duration(seconds: 2));
        yield (ProfileLoaded(places:places,));
      }
      on PlacesNotFoundException{
        yield (ProfileError("Something went wrong"));
      }
      on TimeoutException {
        yield (ProfileError("No Internet Connection"));
      }
    }


    if (event is GetNearestPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (ProfileLoading());
        final places = await profileRepo.fetchNearestPlacesFromDataBase();
        yield (ProfileLoaded(places:places,));
      }

      on PlacesNotFoundException{
        yield (ProfileError("Something went wrong"));
      }
      on TimeoutException {

        yield (ProfileError("No Internet Connection"));
      }
    }


    if (event is GetRecentlyViewedPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (ProfileLoading());
        final places = await profileRepo.fetchRecentlyViewedPlacesFromDataBase();
        yield (ProfileLoaded(places:places));
      }

      on PlacesNotFoundException{
        yield (ProfileError("Something went wrong"));
      }
      on TimeoutException {
        yield (ProfileError("No Internet Connection"));
      }
    }

  }
}