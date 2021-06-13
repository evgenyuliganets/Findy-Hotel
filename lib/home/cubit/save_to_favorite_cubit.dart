import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/bloc/home_bloc.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'save_to_favorite_state.dart';

class SaveToFavoriteCubit extends Cubit<SaveToFavoriteState> {
  final HomeDataRepository homeRepo;
  final placesRepo = PlacesRepository();

  SaveToFavoriteCubit(this.homeRepo) : super(SaveToFavoriteInitial());

  Future<void> addToFavoriteSubmitted(String placeId) async {
    try {
      emit(SaveToFavoriteLoading());
      var place = await homeRepo
          .fetchDetailedPlaceFromNetwork(placeId, saveToFavorite: true)
          .timeout(Duration(seconds: 7));
      if (place.placeId != null) {
        var ifExist = await placesRepo.checkIfExist(place.placeId);
        if (ifExist) {
          emit(SaveToFavoriteLoaded(
              message: "Successfully saved to favorite", ifExist: ifExist));
        }
        else {
          emit(SaveToFavoriteLoaded(
              message: "Cannot save to favorite", ifExist: ifExist));
        }
      }
      else{
        emit(SaveToFavoriteLoaded(
            message: "Cannot save to favorite", ifExist: false));
      }
    } on TimeoutException {
      emit(SaveToFavoriteError("No Internet Connection"));
    }
    on Error {
      emit(SaveToFavoriteError(
          "Something went wrong while adding place in favorite"));
    }
  }

  Future<void> deleteFromFavoriteSubmitted(String placeId) async {
    try {
      emit(SaveToFavoriteLoading());
        await placesRepo.deletePlace(placeId);
        var ifExist = await placesRepo.checkIfExist(placeId);
        if (ifExist) {
          emit(SaveToFavoriteLoaded(
              message: "Successfully saved to favorite", ifExist: ifExist));
        }
        else {
          emit(SaveToFavoriteLoaded(
              message: "Successfully deleted from favorite", ifExist: ifExist));
        }
    }
    on Error {
      emit(SaveToFavoriteError(
          "Something went wrong while deleting place from favorite"));
    }
  }


  Future checkIfExistInFavorite(String placeId) async {
    try {
      emit(SaveToFavoriteLoading());
      var ifExist = await placesRepo.checkIfExist(placeId);
      emit(SaveToFavoriteLoaded(ifExist: ifExist));
    } on Error {
      emit(SaveToFavoriteError(
          "Something went wrong while checking if place exist in favorite"));
    }
  }
}
