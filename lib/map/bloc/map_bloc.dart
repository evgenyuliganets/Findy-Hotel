import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/map/repository/map_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapEvent lastMapEvent;
  SearchFilterModel _filterModel = SearchFilterModel();
  final MapRepository mapRepo;
  final PlacesMapNotFoundException error;
  MapBloc(this.mapRepo, {this.error}) : super(MapInitial());

  @override
  Stream<MapState> mapEventToState(
      MapEvent event,
      ) async* {
    lastMapEvent=event;
    final apiKey = await mapRepo.loadAsset();


    if (event is RefreshPage){
      this.add(event.event);
    }

    if (event is GetPlacesOnMap) {                                   //Get nearby SearchPlaces or Places from dataBase
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
                  ? 'Places was loaded from last known location, try change search mode'
                  : null));
        } else
          throw PlacesMapNotFoundException('Places not found');
      } on TimeoutException {
        yield (MapError("Timeout was reached. No Internet Connection or GPS is not enabled", apiKey,
            textFieldText: event.textFieldText));
          try {
            yield (MapLoading(textFieldText: event.textFieldText));
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield (MapLoaded(
                places: places, message: "All Places was loaded from database",googleApiKey: apiKey, textFieldText: event.textFieldText, filters: event.filters,));
          } on PlacesMapNotFoundException {
            yield (MapError('No places found in database',apiKey));
          }
      } catch (error) {
        if (error is PlacesMapNotFoundException) {
          yield (MapError(error.error, apiKey, textFieldText: event.textFieldText));
          try {
            yield(MapLoading(textFieldText: event.textFieldText));
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield(MapLoaded(places: places, message: "All Places was loaded from database",googleApiKey: apiKey, textFieldText: event.textFieldText, filters: event.filters,));
          } on PlacesMapNotFoundException {
            yield(MapError('No places found in database',apiKey));
          }
          catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield(MapError(Error.error,apiKey));}
            else{
              yield(MapError('Something went wrong, try change filters', apiKey));}
          }
        }
        else {
          if(error is SocketException){
            yield(MapError('No Internet Connection',apiKey));}
          else yield (MapError('Something went wrong, try change filters', apiKey));
          try {
            yield(MapLoading(textFieldText: event.textFieldText));
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            print (places);
            yield(MapLoaded(places: places, message: "All Places was loaded from database",googleApiKey: apiKey, textFieldText: event.textFieldText, filters: event.filters,));
          } on PlacesMapNotFoundException {
            yield(MapError('No places found in database',apiKey));
          }
          catch (Error) {
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield(MapError(Error.error.toString(),apiKey));}
            else{
              yield(MapError('Something went wong in database, try logout',apiKey));}
          }
        }
      }
    }



    if (event is GetMapUserPlaces) {                  //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        print (1);
        yield (MapLoading());
        if(event.mainSearchMode!=null&&event.mainSearchMode){
          final places = await mapRepo.fetchMapPlacesFromNetwork(_filterModel,mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          yield (MapLoaded(places:places, googleApiKey: apiKey,message: 'Places was loaded from last known location'));
        }else{
          print (2);
          final userLocation = await mapRepo.getUserLocation().timeout(Duration(seconds: 7));
          final places = await mapRepo.fetchMapPlacesFromNetwork(_filterModel,latLng: LatLng(userLocation.latitude,userLocation.longitude),mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          print( places.toString());
          yield (MapLoaded(places:places, googleApiKey: apiKey,loc: userLocation, filters: event.filters));
        }
      } on TimeoutException {
        print (3);

        yield (MapError("Timeout was reached. No Internet Connection or GPS is not enabled",apiKey,));
        try {
          yield (MapLoading());
          final places = await mapRepo.fetchAllMapPlacesFromDataBase();
          yield (MapLoaded(
            places: places, message: "All Places was loaded from database", filters: event.filters,googleApiKey: apiKey));
        } on PlacesMapNotFoundException {
          yield (MapError('No places found in database',apiKey));
        }catch (error) {
          yield(MapError('Something went wong in database, try logout',apiKey));
        }
      }
      catch (error) {
        print (4);

        if (error is PlacesMapNotFoundException) {
          yield (MapError(error.error, apiKey,));
          try {
            yield(MapLoading());
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            yield(MapLoaded(places: places, message: "All Places was loaded from database",googleApiKey: apiKey, filters: event.filters,));
          } on PlacesMapNotFoundException {
            yield(MapError('No places found in database',apiKey));
          }
          catch (Error) {
            print (5);

            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield(MapError(Error.error,apiKey));}
            else{
              yield(MapError('Something went wrong, try change filters', apiKey));}
          }
        }
        else {
          if(error is SocketException){
            print (6);
            yield(MapError('No Internet Connection',apiKey));}
          else yield (MapError('Something went wrong, try change filters', apiKey));
          try {
            print (7);
            yield(MapLoading());
            final places = await mapRepo.fetchAllMapPlacesFromDataBase();
            print(places.toString()+"PLACES");
            yield(MapLoaded(places: places, message: "All Places was loaded from database",googleApiKey: apiKey, filters: event.filters,));
          } on PlacesMapNotFoundException {
            print (8);
            yield(MapError('No places found in database',apiKey));
          }
          catch (Error) {
            print (9);
            if (Error is PlacesMapNotFoundException) {
              print(Error.error.toString());
              yield(MapError(Error.error.toString(),apiKey));}
            else{
              yield(MapError('Something went wong in database, try logout',apiKey));}
          }
        }
      }
    }




    if (event is GetMapDetailedPlace) {          //Get DetailedPlace or DetailedPlace from database
      try {
        yield (PlaceLoading());
        final place = await mapRepo.fetchDetailedMapPlaceFromNetwork(event.placeId).timeout(Duration(seconds: 10));
        yield (PlaceLoaded(placesDetail:place, googleApiKey: apiKey));
      }

      on TimeoutException {
        yield (PlaceError("No Internet Connection",apiKey));
        try {
          yield (PlaceLoading());
          final places = await mapRepo.fetchMapPlaceDetailFromDataBase(LatLng(0,0));
          yield (PlaceLoaded(placesDetail: places,message: "Place was loaded from database"));
        }
        on PlacesMapNotFoundException{
          yield (PlaceError(error.error,apiKey));
        }
      }
      catch (Error) {
        if (Error is PlacesMapNotFoundException) {
          yield (PlaceError(Error.error, apiKey,));
          print(Error.error.toString());
        } else {
          print(Error.toString());
          yield (PlaceError('Unknown Error', apiKey,));
        }
      }
    }
  }
  void setFiltersParameters(SearchFilterModel filterModel){
    this._filterModel=filterModel;
    print(this._filterModel.radius);
  }
  SearchFilterModel getFilterModel(){
    return this._filterModel;
  }
}

