import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      timeout(Duration(seconds: 5));
      Future.delayed(Duration(milliseconds: 500));
      if (place.placeId != null) {
          emit(FavoriteLoaded(
              message: AppLocalizations.of(homeRepo.context).successFavorite));}
      else{
        emit(FavoriteLoaded(
            message: AppLocalizations.of(homeRepo.context).errorFavorite));
      }
    } on TimeoutException {
      emit(FavoriteError(AppLocalizations.of(homeRepo.context).noInternetConnection));
    }
    catch (Error) {
      if(Error is SocketException){
        emit(FavoriteError(AppLocalizations.of(homeRepo.context).noInternetConnection));
      }
      else{
      emit(FavoriteError(
          AppLocalizations.of(homeRepo.context).favDatabaseError));
    }}
  }

  Future<void> deleteFromFavoriteSubmitted(String placeId) async {
    try {
      emit(FavoriteLoading());
        await placesRepo.deletePlace(placeId);
        var ifExist = await placesRepo.checkIfExistInFavorite(placeId);
        if (ifExist==false) {
          emit(FavoriteLoaded(
              message: AppLocalizations.of(homeRepo.context).deletedFavorite, ifExist: ifExist));
        }
    }
    on Error {
      emit(FavoriteError(
          AppLocalizations.of(homeRepo.context).deletingFavoriteErr));
    }
  }



}
