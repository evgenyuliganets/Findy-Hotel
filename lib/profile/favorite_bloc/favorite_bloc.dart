import 'dart:async';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteEvent lastProfileEvent;
  final ProfileRepository profileRepo;
  final PlacesNotFoundException error;
  FavoriteBloc(this.profileRepo, {this.error}) : super(ProfileInitial());

  @override
  Stream<FavoriteState> mapEventToState(
      FavoriteEvent event,
      ) async* {
    lastProfileEvent=event;

    if (event is RefreshPage){
      this.add(event.event);
    }

    if (event is GetFavoritePlaces) {           //Get Favorite Places or Places from dataBase
      try {
        yield (FavoriteLoading());
        final places = await profileRepo.fetchFavoritePlacesFromDataBase().timeout(Duration(seconds: 2));
        yield (FavoriteLoaded(places:places,));
      }
      on PlacesNotFoundException{
        yield (FavoriteError("Something went wrong"));
      }
      on TimeoutException {
        yield (FavoriteError("No Internet Connection"));
      }
    }


    if (event is GetNearestPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (FavoriteLoading());
        final places = await profileRepo.fetchNearestPlacesFromDataBase();
        yield (FavoriteLoaded(places:places,));
      }

      on PlacesNotFoundException{
        yield (FavoriteError("Something went wrong"));
      }
      on TimeoutException {

        yield (FavoriteError("No Internet Connection"));
      }
    }

  }
}