import 'dart:async';
import 'package:find_hotel/home/data_repository/places_data.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataRepository homeRepo;
  final PlacesNotFoundException error;
  HomeBloc(this.homeRepo, {this.error}) : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is GetPlaces) {           //Get nearby Places or Places from dataBase
      try {
        yield (HomeLoading());
        final places = await homeRepo.fetchPlacesFromNetwork(event.latlng).timeout(Duration(seconds: 2));
        final apiKey = await homeRepo.loadAsset();
        yield (HomeLoaded(places:places,googleApiKey: apiKey));
      }

      on TimeoutException {
        yield (HomeError("No Internet Connection"));
        try {
          yield (HomeLoading());
          final places = await homeRepo.fetchPlacesFromDataBase(event.latlng);
          yield (HomeLoaded(places: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (HomeError(error.error));
        }
      }
    }
    if (event is GetUserPlaces) {           //Get nearby UserPlaces or UserPlaces from dataBase
      try {
        yield (HomeLoading());
        final userLocation = await homeRepo.getUserLocation().timeout(Duration(seconds: 7));
        final places = await homeRepo.fetchPlacesFromNetwork(LatLng(userLocation.latitude,userLocation.longitude)).timeout(Duration(seconds: 2));
        final apiKey = await homeRepo.loadAsset();
        yield (HomeLoaded(places:places, googleApiKey: apiKey));
      }

      on TimeoutException {
        yield (HomeError("No Internet Connection"));
        try {
          yield (HomeLoading());
          final places = await homeRepo.fetchPlacesFromDataBase(LatLng(0,0));
          yield (HomeLoaded(places: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (HomeError(error.error));
        }
      }
    }

    if (event is GetDetailedPlace) {          //Get DetailedPlace or DetailedPlace from database
      try {
        yield (PlaceLoading());
        final place = await homeRepo.fetchDetailedPlaceFromNetwork(event.placeId).timeout(Duration(seconds: 10));
        final apiKey = await homeRepo.loadAsset();
        yield (PlaceLoaded(placesDetail:place, googleApiKey: apiKey));
      }

      on TimeoutException {
        yield (PlaceError("No Internet Connection"));
        try {
          yield (HomeLoading());
          final places = await homeRepo.fetchPlaceDetailFromDataBase(LatLng(0,0));
          yield (PlaceLoaded(placesDetail: places,message: "Places was loaded from database"));
        }
        on PlacesNotFoundException{
          yield (PlaceError(error.error));
        }
      }
    }
  }
}
