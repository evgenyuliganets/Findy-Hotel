import 'dart:async';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepo;
  final PlacesNotFoundException error;
  ProfileBloc(this.profileRepo, {this.error}) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
      ProfileEvent event,
      ) async* {
    if (event is GetPlaces) {           //Get nearby Places or Places from dataBase
      try {
        yield (ProfileLoading());
        final places = await profileRepo.fetchPlacesFromNetwork(event.latlng).timeout(Duration(seconds: 2));
        final username = await profileRepo.getUsername();
        yield (ProfileLoaded(places:places,username: username));
      }

      on TimeoutException {
        yield (ProfileError("No Internet Connection"));
        try {
          yield (ProfileLoading());
          final places = await profileRepo.fetchPlacesFromDataBase(event.latlng);
          yield (ProfileLoaded(places: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (ProfileError(error.error));
        }
      }
    }
    if (event is GetUserPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (ProfileLoading());
        final userLocation = await profileRepo.getUserLocation().timeout(Duration(seconds: 7));
        final places = await profileRepo.fetchPlacesFromNetwork(LatLng(userLocation.latitude,userLocation.longitude)).timeout(Duration(seconds: 2));
        final username = await profileRepo.getUsername();
        yield (ProfileLoaded(places:places,username: username));
      }

      on TimeoutException {
        yield (ProfileError("No Internet Connection"));
        try {
          yield (ProfileLoading());
          final places = await profileRepo.fetchPlacesFromDataBase(LatLng(0,0));
          yield (ProfileLoaded(places: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (ProfileError(error.error));
        }
      }
    }
  }
}