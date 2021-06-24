import 'dart:async';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/profile/data_repository/profile_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


part 'favorite_event.dart';
part 'favorite_state.dart';
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
        final places = await profileRepo.fetchFavoritePlacesFromDataBase().timeout(Duration(seconds: 10));
        yield (FavoriteLoaded(places:places,));
      }
      on PlacesNotFoundException{
        yield (FavoriteError(AppLocalizations.of(profileRepo.context).favoriteError,
        ));
      }
      catch (error){
        if (!(error is PlacesNotFoundException)){
          yield (FavoriteError(AppLocalizations.of(profileRepo.context).placesFromDatabaseCriticalErr));
        }
      }
    }


    if (event is GetNearestPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (FavoriteLoading());
        final places = await profileRepo.fetchNearestPlacesFromDataBase();
        yield (FavoriteLoaded(places:places,));
      }

      on PlacesNotFoundException{
        yield (FavoriteError("Something went wrong in database"));
      }
      catch (error){
        if (!(error is PlacesNotFoundException)){
          yield (FavoriteError("Something went wrong"));
        }
      }
    }

  }
}