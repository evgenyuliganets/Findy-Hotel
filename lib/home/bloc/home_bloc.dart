import 'dart:async';
import 'dart:io';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeEvent lastHomeEvent;
  SearchFilterModel _filterModel = SearchFilterModel();
  final HomeDataRepository homeRepo;
  final PlacesNotFoundException error;

  HomeBloc(this.homeRepo, {this.error}) : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    lastHomeEvent = event;
    final apiKey = await homeRepo.loadAsset();

    if (event is RefreshPage) {
      this.add(event.event);
    }

    if (event is GetPlaces) {
      final apiKey = await homeRepo.loadAsset();
      //Get nearby SearchPlaces or Places from dataBase
      try {
        yield (HomeLoading(apiKey,textFieldText: event.textFieldText));
        final places = await homeRepo
            .fetchPlacesFromNetwork(_filterModel,
                latLng: event.latlng ?? null,
                textFieldText: event.textFieldText,
                mainSearchMode: event.mainSearchMode)
            .timeout(Duration(seconds: 4));
        if (places.isNotEmpty) {
          print(places.toString());
          yield (HomeLoaded(
              places: places,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
              message: (event.textFieldText == null &&
                          event.mainSearchMode == true &&
                          event.filters.rankBy == false) ||
                      (event.textFieldText == '' &&
                          event.mainSearchMode == true &&
                          event.filters.rankBy == false)
                  ? AppLocalizations.of(homeRepo.context).lastLocationNotify
                  : null));
        } else
          throw PlacesNotFoundException(AppLocalizations.of(homeRepo.context).noResultsErr);
      } on TimeoutException {
        yield (HomeError(
            AppLocalizations.of(homeRepo.context).placesTimeoutExt,
            apiKey,
            textFieldText: event.textFieldText));
        try {
          yield (HomeLoading(apiKey,textFieldText: event.textFieldText));
          final places = await homeRepo.fetchAllPlacesFromDataBase();
          yield (HomeLoaded(
            places: places,
            message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
            googleApiKey: apiKey,
            textFieldText: event.textFieldText,
            filters: event.filters,
          ));
        } on PlacesNotFoundException {
          yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
        }
      } catch (error) {
        if (error is PlacesNotFoundException) {
          yield (HomeError(error.error, apiKey,
              textFieldText: event.textFieldText));
          try {
            yield (HomeLoading(apiKey,textFieldText: event.textFieldText));
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
              places: places,
              message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesNotFoundException {
            yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
          } catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield (HomeError(error.error.toString(), apiKey));
            } else {
              yield (HomeError(
                  AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        } else {
          if (error is SocketException) {
            yield (HomeError(AppLocalizations.of(homeRepo.context).noInternetConnection, apiKey));
          } else
            yield (HomeError(
                AppLocalizations.of(homeRepo.context).unknownErrorExt, apiKey));
          try {
            yield (HomeLoading(apiKey,textFieldText: event.textFieldText));
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
              places: places,
              message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesNotFoundException {
            yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
          } catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield (HomeError(error.error.toString(), apiKey));
            } else {
              yield (HomeError(
                  AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        }
      }
    }

    if (event is GetUserPlaces) {
      //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (HomeLoading(apiKey));
        if (event.mainSearchMode != null && event.mainSearchMode) {
          final places = await homeRepo
              .fetchPlacesFromNetwork(
                _filterModel,
                mainSearchMode: event.mainSearchMode ?? null,
              )
              .timeout(Duration(seconds: 4));
          yield (HomeLoaded(
            places: places,
            googleApiKey: apiKey,
            message: AppLocalizations.of(homeRepo.context).lastLocationNotify,
            filters: event.filters,
          ));
        } else {
          final userLocation =
              await homeRepo.getUserLocation().timeout(Duration(seconds: 7));
          final places = await homeRepo
              .fetchPlacesFromNetwork(
                _filterModel,
                latLng: LatLng(userLocation.latitude, userLocation.longitude),
                mainSearchMode: event.mainSearchMode ?? null,
              )
              .timeout(Duration(seconds: 2));
          print(places.toString());
          yield (HomeLoaded(
              places: places,
              googleApiKey: apiKey,
              loc: userLocation,
              filters: event.filters));
        }
      } on TimeoutException {
        yield (HomeError(
            AppLocalizations.of(homeRepo.context).placesTimeoutExt,
            apiKey));
        try {
          yield (HomeLoading(apiKey,));
          final places = await homeRepo.fetchAllPlacesFromDataBase();
          yield (HomeLoaded(
            places: places,
            message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
            googleApiKey: apiKey,
            textFieldText: event.textFieldText,
            filters: event.filters,
          ));
        } on PlacesNotFoundException {
          yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
        } catch (error) {
          yield (HomeError(
              AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
        }
      } catch (error) {
        if (error is PlacesNotFoundException) {
          yield (HomeError(error.error, apiKey));
          try {
            yield (HomeLoading(apiKey,));
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
              places: places,
              message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesNotFoundException {
            yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
          } catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield (HomeError(error.error.toString(), apiKey));
            } else {
              yield (HomeError(
                  AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        } else {
          if (error is SocketException) {
            yield (HomeError(AppLocalizations.of(homeRepo.context).noInternetConnection, apiKey));
          } else
            yield (HomeError(
                AppLocalizations.of(homeRepo.context).unknownErrorExt, apiKey));
          try {
            yield (HomeLoading(apiKey,));
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
              places: places,
              message: AppLocalizations.of(homeRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesNotFoundException {
            yield (HomeError(AppLocalizations.of(homeRepo.context).placesFromDatabaseErr, apiKey));
          } catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield (HomeError(error.error.toString(), apiKey));
            } else {
              yield (HomeError(
                  AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        }
      }
    }

    if (event is GetDetailedPlace) {
      //Get DetailedPlace or DetailedPlace from database
      try {
        yield (PlaceLoading());
        final place = await homeRepo
            .fetchDetailedPlaceFromNetwork(event.placeId,
                isRecentlyViewed: true)
            .timeout(Duration(seconds: 4));
        yield (PlaceLoaded(placesDetail: place, googleApiKey: apiKey));
      } on TimeoutException {
        yield PlaceError(AppLocalizations.of(homeRepo.context).placesTimeoutNetwork, apiKey);
        try {
          yield (PlaceLoading());
          final places =
              await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
          yield (PlaceLoaded(
              placesDetail: places, message: AppLocalizations.of(homeRepo.context).placeFromDatabase));
        } on PlacesNotFoundException {
          yield (PlaceError(AppLocalizations.of(homeRepo.context).placeDatabaseErr, apiKey));
        } catch (Error) {
          if (Error is PlacesNotFoundException) {
            print(Error.error.toString());
            yield (PlaceError(Error.error, apiKey));
          } else {
            yield (PlaceError(Error.toString(), apiKey));
          }
        }
      } catch (error) {
        if (error is PlacesNotFoundException) {
          yield (PlaceError(error.error, apiKey));
          try {
            yield (PlaceLoading());
            final places =
                await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield (PlaceLoaded(
                placesDetail: places,
                message: AppLocalizations.of(homeRepo.context).placeFromDatabase));
          } on PlacesNotFoundException {
            yield (PlaceError(AppLocalizations.of(homeRepo.context).placeDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesNotFoundException) {
              print(Error.error.toString());
              yield (PlaceError(Error.error, apiKey));
            } else {
              yield (PlaceError(Error.toString(), apiKey));
            }
          }
        } else {
          if (error is SocketException) {
            yield (PlaceError(AppLocalizations.of(homeRepo.context).placesTimeoutNetwork, apiKey));
          }
          try {
            yield (PlaceLoading());
            final places =
                await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield (PlaceLoaded(
                placesDetail: places,
                message: AppLocalizations.of(homeRepo.context).placeFromDatabase));
          } on PlacesNotFoundException {
            yield (PlaceError(AppLocalizations.of(homeRepo.context).placeDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesNotFoundException) {
              print(Error.error.toString());
              yield (PlaceError(Error.error, apiKey));
            } else {
              print(Error.toString() + " MY");
              yield (PlaceError(
                  AppLocalizations.of(homeRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        }
      }
    }
  }

  void setFiltersParameters(SearchFilterModel filterModel) {
    this._filterModel = filterModel;
    print(this._filterModel.radius);
  }

  SearchFilterModel getFilterModel() {
    return this._filterModel;
  }
}
