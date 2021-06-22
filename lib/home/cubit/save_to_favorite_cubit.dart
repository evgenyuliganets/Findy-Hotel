import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:meta/meta.dart';

part 'save_to_favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final HomeDataRepository homeRepo;
  final placesRepo = PlacesRepository();

  FavoriteCubit(this.homeRepo) : super(FavoriteInitial());

  Future<void> addToFavoriteSubmitted(String placeId) async {
    try {
      emit(FavoriteLoading());
      var place = await homeRepo.
      fetchDetailedPlaceFromNetwork(placeId, saveToFavorite: true).
      timeout(Duration(seconds: 7));
      if (place.placeId != null) {
          emit(FavoriteLoaded(
              message: "Successfully saved to favorite"));}
      else{
        print(5);
        emit(FavoriteLoaded(
            message: "Cannot save to favorite"));
      }
    } on TimeoutException {
      emit(FavoriteError("No Internet Connection"));
    }
    on Error {
      print(5);
      emit(FavoriteError(
          "Something went wrong while adding place in favorite"));
    }
  }

  Future<void> deleteFromFavoriteSubmitted(String placeId) async {
    try {
      emit(FavoriteLoading());
        await placesRepo.deletePlace(placeId);
        var ifExist = await placesRepo.checkIfExistInFavorite(placeId);
        if (ifExist==false) {
          emit(FavoriteLoaded(
              message: "Successfully deleted from favorite", ifExist: ifExist));
        }
    }
    on Error {
      emit(FavoriteError(
          "Something went wrong while deleting place from favorite"));
    }
  }



}
