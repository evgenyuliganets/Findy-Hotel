import 'dart:async';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
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
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    lastHomeEvent=event;
    final apiKey = await homeRepo.loadAsset();

    if (event is RefreshPage){
      this.add(event.event);
    }

    if (event is GetPlaces) {                                   //Get nearby SearchPlaces or Places from dataBase
      try {
        yield (HomeLoading());
        print(event.latlng);
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
                  event.filters.rankBy==false) ||
                  (event.textFieldText == '' &&
                      event.mainSearchMode == true &&
                      event.filters.rankBy==false)
                  ? 'Places was loaded from last known location, try change search mode'
                  : null
          ));
        } else
          throw PlacesNotFoundException('Places not found');
      } on TimeoutException {
        yield (HomeError("No Internet Connection", apiKey,
            textFieldText: event.textFieldText));
          try {
            print (1);
            yield (HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
                places: places, message: "Places was loaded from database"));
          } on PlacesNotFoundException {
            print (2);
            yield (HomeError('No places found in database',apiKey));
          }
      } catch (Error) {
        print (3);
        if (Error is PlacesNotFoundException) {
          yield (HomeError(Error.error, apiKey,
              textFieldText: event.textFieldText));
          print(Error.error.toString());
        } else {
          print (4);
          print(Error.toString());
          yield (HomeError('Something went wrong, try change filters', apiKey,
              textFieldText: event.textFieldText));
        }
      }
    }



    if (event is GetUserPlaces) {                  //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (HomeLoading());
        if(event.mainSearchMode!=null&&event.mainSearchMode){
          final places = await homeRepo.fetchPlacesFromNetwork(_filterModel,mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
          yield (HomeLoaded(places:places, googleApiKey: apiKey,message: 'Places was loaded from last known location'));
        }else{
        final userLocation = await homeRepo.getUserLocation().timeout(Duration(seconds: 7));
        final places = await homeRepo.fetchPlacesFromNetwork(_filterModel,latLng: LatLng(userLocation.latitude,userLocation.longitude),mainSearchMode: event.mainSearchMode??null,).timeout(Duration(seconds: 2));
        print( places.toString());
        yield (HomeLoaded(places:places, googleApiKey: apiKey,loc: userLocation));
        }
      } on TimeoutException {
        yield (HomeError("No Internet Connection",apiKey,));
        if(event is GetPlacesFromDB) {
          try {
            yield (HomeLoading());
            final places = await homeRepo.fetchAllPlacesFromDataBase();
            yield (HomeLoaded(
                places: places, message: "Places was loaded from database"));
          }
          on PlacesNotFoundException {
            yield (HomeError(error.error, apiKey));
          }
        }
      }
      catch (Error){
        if(Error is PlacesNotFoundException) {
          yield (HomeError(
              error.error, apiKey,));
          print(error.error.toString());
        }
        else{
          print(Error.toString());
          yield (HomeError(
              'Unknown Error', apiKey));
        }
      }
    }


    if (event is GetDetailedPlace) {          //Get DetailedPlace or DetailedPlace from database
      print(event);
      print(event.placeId);
      try {
        yield (PlaceLoading());
        final place = await homeRepo.fetchDetailedPlaceFromNetwork(event.placeId).timeout(Duration(seconds: 10));
        yield (PlaceLoaded(placesDetail:place, googleApiKey: apiKey));
      }
      on TimeoutException {
        yield (PlaceError("No Internet Connection"));
        try {
          yield (PlaceLoading());
          final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
          yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (PlaceError('This place was found in database'));
        }
        catch (Error) {
          if (Error is PlacesNotFoundException) {
            try {
              yield (PlaceLoading());
              final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
              yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
            }
            on PlacesNotFoundException{
              yield (PlaceError('This place was not found in database'));
            }
            yield (PlaceError(Error.error));
            print(Error.error.toString());
          } else {
            print(Error.toString());
            yield (PlaceError('Unknown Error'));
            yield (PlaceLoading());
            final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
          }
        }
      }
      catch (Error) {
        if (Error is PlacesNotFoundException) {
          try {
            yield (PlaceError(Error.error));
          print(Error.error.toString());
            yield (PlaceLoading());
            final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
            yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
          }
          on PlacesNotFoundException{
            yield (PlaceError('This place was not found in database'));
          }
        } else {
          yield (PlaceError('Unknown Error'));
          yield (PlaceLoading());
          final places = await homeRepo.fetchPlaceDetailFromDataBase(event.placeId);
          yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
        }
      }
    }
  }
  void setFiltersParametrs(SearchFilterModel filterModel){
    this._filterModel=filterModel;
    print(this._filterModel.radius);
  }
  SearchFilterModel getFilterModel(){
    return this._filterModel;
  }
}
