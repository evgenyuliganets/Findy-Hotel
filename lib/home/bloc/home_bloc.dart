import 'dart:async';
import 'dart:io';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:find_hotel/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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
    lastHomeEvent=event;
    final apiKey = await homeRepo.loadAsset();

    if (event is RefreshPage){
      this.add(event.event);
    }

    if (event is GetPlaces) {                       //Get nearby SearchPlaces or Places from dataBase
      try {
        yield (HomeLoading(textFieldText: event.textFieldText));
        final places = await homeRepo
            .fetchPlacesFromNetwork(_filterModel,
                latLng: event.latlng ?? null,
                textFieldText: event.textFieldText,
                mainSearchMode: event.mainSearchMode)
            .timeout(Duration(seconds: 2));
        final apiKey = await homeRepo.loadAsset();
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
                  ? 'Places was loaded from last known location, try change search mode'
                  : null));
        } else
          throw PlacesNotFoundException('Places not found');
      } on TimeoutException {
        yield (HomeError("Timeout was reached. No Internet Connection or GPS is not enabled", apiKey,
            textFieldText: event.textFieldText));
          try {
            yield (HomeLoading(textFieldText: event.textFieldText));
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
                places: places, message: "All Places was loaded from database",googleApiKey: apiKey, textFieldText: event.textFieldText, filters: event.filters,));
          } on PlacesNotFoundException {
            yield (HomeError('No places found in database',apiKey));
          }
      } catch (error) {
        if (error is PlacesNotFoundException) {
          yield (HomeError(error.error, apiKey));
          try {
            yield(HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield(HomeLoaded(places: places, message: "All Places was loaded from database", filters: event.filters,));
          } on PlacesNotFoundException {
            yield(HomeError('No places found in database',apiKey));
          }
          catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield(HomeError(error.error.toString(),apiKey));}
            else{
              yield(HomeError('Something went wrong in database, try logout',apiKey));}
          }
        }
        else {
          if(error is SocketException){
            yield(HomeError('No Internet Connection',apiKey));}
          else yield (HomeError('Something went wrong, try change filters', apiKey));
          try {
            yield(HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield(HomeLoaded(places: places, message: "All Places was loaded from database", filters: event.filters,));
          } on PlacesNotFoundException {
            yield(HomeError('No places found in database',apiKey));
          }
          catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield(HomeError(error.error.toString(),apiKey));}
            else{
              yield(HomeError('Something went wrong in database, try logout',apiKey));}
          }
        }
      }
    }



    if (event is GetUserPlaces) {                  //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (HomeLoading());
        if(event.mainSearchMode!=null&&event.mainSearchMode){
          final places = await homeRepo.fetchPlacesFromNetwork(_filterModel,mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 3));
          yield (HomeLoaded(
            places:places,
            googleApiKey:
            apiKey,
            message: 'Places was loaded from last known location',
            filters: event.filters,));
        }else{
          final userLocation = await homeRepo.getUserLocation().timeout(Duration(seconds: 7));
          final places = await homeRepo.fetchPlacesFromNetwork(_filterModel,latLng: LatLng(userLocation.latitude,userLocation.longitude),mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          print( places.toString());
          yield (HomeLoaded(places:places, googleApiKey: apiKey,loc: userLocation, filters: event.filters));
        }
      } on TimeoutException {
        yield (HomeError("Timeout was reached. No Internet Connection or GPS is not enabled", apiKey));
        try {
          yield (HomeLoading());
          final places = await homeRepo.fetchAllPlacesFromDataBase();
          yield (HomeLoaded(
              places: places, message: "All Places was loaded from database", filters: event.filters,googleApiKey: apiKey));
        } on PlacesNotFoundException {
          yield (HomeError('No places found in database',apiKey));
        }catch (error) {
          yield(HomeError('Something went wong in database, try logout',apiKey));
        }
      } catch (error) {
        if (error is PlacesNotFoundException) {
          yield (HomeError(error.error, apiKey));
          try {
            yield(HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield(HomeLoaded(places: places, message: "All Places was loaded from database", filters: event.filters,));
          } on PlacesNotFoundException {
            yield(HomeError('No places found in database',apiKey));
          }
          catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield(HomeError(error.error.toString(),apiKey));}
            else{
              yield(HomeError('Something went wrong in database, try logout',apiKey));}
          }
        }
        else {
          if(error is SocketException){
            yield(HomeError('No Internet Connection',apiKey));}
          else yield (HomeError('Something went wrong, try change filters', apiKey));
          try {
            yield(HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield(HomeLoaded(places: places, message: "All Places was loaded from database", filters: event.filters,));
          } on PlacesNotFoundException {
            yield(HomeError('No places found in database',apiKey));
          }
          catch (error) {
            if (error is PlacesNotFoundException) {
              print(error.error.toString());
              yield(HomeError(error.error.toString(),apiKey));}
            else{
              yield(HomeError('Something went wrong in database, try logout',apiKey));}
          }
        }
      }
    }


    if (event is GetDetailedPlace) {          //Get DetailedPlace or DetailedPlace from database
      try {
        yield (PlaceLoading());
        final place = await homeRepo.fetchDetailedPlaceFromNetwork(event.placeId,isRecentlyViewed: true).timeout(Duration(seconds: 2));
        yield (PlaceLoaded(placesDetail:place, googleApiKey: apiKey));
      }

      on TimeoutException {
        yield PlaceError("Timeout was reached. No Internet Connection");
          try {
            yield(PlaceLoading());
            final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield(PlaceLoaded(
                placesDetail: places, message: "Place was loaded from database"));
          } on PlacesNotFoundException {
            yield(PlaceError('This place was not found in database'));
          }
          catch (Error) {
            if (Error is PlacesNotFoundException) {
              print(Error.error.toString());
              yield(PlaceError(Error.error));}
            else{
              yield(PlaceError(Error.toString()));}
          }
        }
      catch (error) {
        if (error is PlacesNotFoundException) {
          yield(PlaceError(error.error));
          try {
            yield(PlaceLoading());
            final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield(PlaceLoaded(
                placesDetail: places, message: "Place was loaded from database"));
          } on PlacesNotFoundException {
            yield(PlaceError('This place was not found in database'));
          }
          catch (Error) {
            if (Error is PlacesNotFoundException) {
              print(Error.error.toString());
              yield(PlaceError(Error.error));}
            else{
              yield(PlaceError(Error.toString()));}
          }
        } else {
          if(error is SocketException){
          yield(PlaceError('No Internet Connection'));}
          else yield(PlaceError('Something went wrong, try again later'));
          try {
            yield(PlaceLoading());
            final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield(PlaceLoaded(
                placesDetail: places, message: "Place was loaded from database"));
          } on PlacesNotFoundException {
            yield(PlaceError('This place was not found in database'));
          }
          catch (Error) {
            if (Error is PlacesNotFoundException) {
              print(Error.error.toString());
              yield(PlaceError(Error.error));}
            else{
              print(Error.toString()+" MY");
              yield(PlaceError('Something went wrong, try again later'));}
          }
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
