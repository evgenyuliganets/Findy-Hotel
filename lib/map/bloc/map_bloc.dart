import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/map/repository/map_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapEvent lastMapEvent;
  SearchFilterModel _filterModel = SearchFilterModel();
  final MapRepository mapRepo;
  final PlacesMapNotFoundException error;

  MapBloc(this.mapRepo, {this.error}) : super(MapInitial());

  @override
  Stream<MapState> mapEventToState(MapEvent event,) async* {
    lastMapEvent = event;
    final apiKey = await mapRepo.loadAsset();

    if (event is RefreshPage) {
      this.add(event.event);
    }

    if (event is GetPlacesOnMap) {
      //Get nearby SearchPlaces or Places from dataBase
      try {
        yield (MapLoading(textFieldText: event.textFieldText));
        final places = await mapRepo
            .fetchMapPlacesFromNetwork(_filterModel,
                latLng: event.latlng ?? null,
                textFieldText: event.textFieldText,
                mainSearchMode: event.mainSearchMode)
            .timeout(Duration(seconds: 2));
        final apiKey = await mapRepo.loadAsset();
        if (places.isNotEmpty) {
          print(places.toString());
          yield (MapLoaded(
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
                  ? AppLocalizations.of(mapRepo.context).lastLocationExtNotify
                  : null));
        } else
          throw PlacesMapNotFoundException(AppLocalizations.of(mapRepo.context).noResultsErr);
      } on TimeoutException {
        yield (MapError(
            AppLocalizations.of(mapRepo.context).placesTimeoutExt,
            apiKey,
            textFieldText: event.textFieldText));
        try {
          yield (MapLoading(textFieldText: event.textFieldText));
          final places = await mapRepo.fetchAllMapPlacesFromDataBase();
          yield (MapLoaded(
            places: places,
            message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
            googleApiKey: apiKey,
            textFieldText: event.textFieldText,
            filters: event.filters,
          ));
        } on PlacesMapNotFoundException {
          yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
        }
      } catch (error) {
        if (error is PlacesMapNotFoundException) {
          yield (MapError(error.error, apiKey,
              textFieldText: event.textFieldText));
          try {
            yield (MapLoading(textFieldText: event.textFieldText,googleApiKey: apiKey));
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield (MapLoaded(
              places: places,
              message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesMapNotFoundException {
            yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield (MapError(Error.error, apiKey));
            } else {
              yield (MapError(
                  AppLocalizations.of(mapRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        } else {
          if (error is SocketException) {
            yield (MapError(AppLocalizations.of(mapRepo.context).noInternetConnection, apiKey));
          } else
            yield (MapError(
                AppLocalizations.of(mapRepo.context).unknownErrorExt, apiKey));
          try {
            yield (MapLoading(textFieldText: event.textFieldText,googleApiKey: apiKey));
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield (MapLoaded(
              places: places,
              message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
            ));
          } on PlacesMapNotFoundException {
            yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield (MapError(Error.error.toString(), apiKey));
            } else {
              yield (MapError(
                  AppLocalizations.of(mapRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        }
      }
    }

    if (event is GetMapUserPlaces) {
      //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (MapLoading(googleApiKey: apiKey));
        if (event.mainSearchMode != null && event.mainSearchMode) {
          final places = await mapRepo
              .fetchMapPlacesFromNetwork(
                _filterModel,
                mainSearchMode: event.mainSearchMode ?? null,
              )
              .timeout(Duration(seconds: 4));
          yield (MapLoaded(
            places: places,
            googleApiKey: apiKey,
            message: AppLocalizations.of(mapRepo.context).lastLocationNotify,
            filters: event.filters,
          ));
        } else {
          final userLocation =
              await mapRepo.getUserLocation().timeout(Duration(seconds: 7));
          final places = await mapRepo
              .fetchMapPlacesFromNetwork(
                _filterModel,
                latLng: LatLng(userLocation.latitude, userLocation.longitude),
                mainSearchMode: event.mainSearchMode ?? null,
              )
              .timeout(Duration(seconds: 2));
          print(places.toString());
          yield (MapLoaded(
              places: places,
              googleApiKey: apiKey,
              loc: userLocation,
              filters: event.filters));
        }
      } on TimeoutException {
        yield (MapError(
          AppLocalizations.of(mapRepo.context).placesTimeoutExt,
          apiKey,
        ));
        try {
          yield (MapLoading());
          final places = await mapRepo.fetchAllMapPlacesFromDataBase();
          yield (MapLoaded(
              places: places,
              message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
              filters: event.filters,
              googleApiKey: apiKey
          ));
        } on PlacesMapNotFoundException {
          yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
        } catch (error) {
          yield (MapError(
              AppLocalizations.of(mapRepo.context).placesFromDatabaseCriticalErr, apiKey));
        }
      } catch (error) {
        if (error is PlacesMapNotFoundException) {
          yield (MapError(error.error, apiKey,));
          try {
            yield (MapLoading());
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield (MapLoaded(
              places: places,
              message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              filters: event.filters,
            ));
          } on PlacesMapNotFoundException {
            yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield (MapError(Error.error, apiKey));
            } else {
              yield (MapError(
                  AppLocalizations.of(mapRepo.context).placesFromDatabaseCriticalErr, apiKey));
            }
          }
        } else {
          if (error is SocketException) {
            yield (MapError(AppLocalizations.of(mapRepo.context).noInternetConnection, apiKey));
          } else
            yield (MapError(
                AppLocalizations.of(mapRepo.context).unknownErrorExt, apiKey));
          try {
            yield (MapLoading());
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield (MapLoaded(
              places: places,
              message: AppLocalizations.of(mapRepo.context).placesFromDatabase,
              googleApiKey: apiKey,
              filters: event.filters,
            ));
          } on PlacesMapNotFoundException {
            yield (MapError(AppLocalizations.of(mapRepo.context).placesFromDatabaseErr, apiKey));
          } catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield (MapError(Error.error.toString(), apiKey));
            } else {
              yield (MapError(
                  AppLocalizations.of(mapRepo.context).placesFromDatabaseCriticalErr, apiKey));
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
