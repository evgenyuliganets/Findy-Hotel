import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;

class HomeDataRepository {
  Future<List<PlacesSearchResult>> fetchPlacesFromNetwork(LatLng latLng) async {
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final location = Location(latLng.latitude, latLng.longitude);
      final result = await _places.searchNearbyWithRadius(location, 2500 ,type:"lodging",language: defaultLocale);
        if (result.status == "OK"&&result.results.isNotEmpty) {
            return result.results;
        }
        else{throw result.errorMessage;}
    }
    catch(Error){
      throw PlacesNotFoundException(Error.toString());
    }
  }
  Future<LatLng> getUserLocation() async {
    var currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await Future.any([
        location.getLocation(),
        Future.delayed(Duration(seconds: 3), () => null),
      ]).timeout(Duration(seconds: 3));
      if (currentLocation == null) {
        currentLocation = await location.getLocation();
      }
      final center = LatLng(currentLocation.latitude, currentLocation.longitude);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  fetchPlacesFromDataBase(userName) {

  }
/*If you are using this app u should create your own asset file with text instance of ApiKey for GooglePlaces
  more info on https://developers.google.com/maps/documentation/places/web-service/get-api-key */
Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/sensitive.txt');
}
}
class PlacesNotFoundException implements Exception {
  final String error;
  PlacesNotFoundException(this.error);
}