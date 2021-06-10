import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/map/repository/map_repository.dart';
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
        yield (MapLoading());
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
              marker: event.marker,
              places: places,
              googleApiKey: apiKey,
              textFieldText: event.textFieldText,
              filters: event.filters,
              message: (event.textFieldText == null &&
                      event.mainSearchMode == true &&
                  event.filters.rankBy==false) ||
                  (event.textFieldText == '' &&
                              event.mainSearchMode == true &&
                              event.filters.rankBy==false)
                          ? 'Places was loaded from last known location, try change search mode'
                          : null));
          print(event.textFieldText==''&&event.mainSearchMode==true);
        } else
          throw PlacesMapNotFoundException('Places not found');
      } on TimeoutException {
        yield (MapError("No Internet Connection", apiKey,
            textFieldText: event.textFieldText));
        if (event is GetMapPlacesFromDB) {
          try {
            yield (MapLoading());
            final places = await mapRepo.fetchPlacesFromDataBase();
            yield (MapLoaded(
                places: places, message: "Places was loaded from database"));
          } on PlacesMapNotFoundException {
            yield (MapError('No places found in database',apiKey));
          }
        }
      } catch (Error) {
        if (Error is PlacesMapNotFoundException) {
          yield (MapError(Error.error, apiKey,
              textFieldText: event.textFieldText));
          print(Error.error.toString());
        } else {
          print(Error.toString());
          yield (MapError('Something went wrong, try change filters', apiKey,
              textFieldText: event.textFieldText));
        }
      }
    }



    if (event is GetMapUserPlaces) {                  //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (MapLoading());
        if(event.mainSearchMode!=null&&event.mainSearchMode){
          final places = await mapRepo.fetchMapPlacesFromNetwork(_filterModel,mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          yield (MapLoaded(places:places, googleApiKey: apiKey,message: 'Places was loaded from last known location'));
        }else{
          final userLocation = await mapRepo.getUserLocation().timeout(Duration(seconds: 7));
          final places = await mapRepo.fetchMapPlacesFromNetwork(_filterModel,latLng: LatLng(userLocation.latitude,userLocation.longitude),mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          print( places.toString());
          yield (MapLoaded(places:places, googleApiKey: apiKey,loc: userLocation));
        }
      } on TimeoutException {
        yield (MapError("No Internet Connection",apiKey,));
        if(event is GetMapPlacesFromDB) {
          try {
            yield (MapLoading());
            final places = await mapRepo.fetchPlacesFromDataBase();
            yield (MapLoaded(
                places: places, message: "Places was loaded from database"));
          }
          on PlacesMapNotFoundException {
            yield (MapError(error.error, apiKey));
          }
        }
      }
      catch (Error){
        if(Error is PlacesMapNotFoundException) {
          yield (MapError(
            Error.error, apiKey,));
          print(Error.error.toString());
        }
        else{
          print(Error.toString());
          yield (MapError(
              'Something went wrong, try change filters', apiKey));
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
        yield (PlaceError("No Internet Connection"));
        try {
          yield (MapLoading());
          final places = await mapRepo.fetchPlaceDetailFromDataBase(LatLng(0,0));
          yield (PlaceLoaded(placesDetail: places,message: "Place was loaded from database"));
        }
        on PlacesMapNotFoundException{
          yield (PlaceError(error.error));
        }
      }
      catch (Error) {
        if (Error is PlacesMapNotFoundException) {
          yield (MapError(Error.error, apiKey,));
          print(Error.error.toString());
        } else {
          print(Error.toString());
          yield (MapError('Unknown Error', apiKey,));
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

