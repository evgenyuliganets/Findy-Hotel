import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';


class HomeDataRepository {
  Future<List<PlacesSearchResult>> fetchPlacesFromNetwork(LatLng latLng) async {
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final location = Location(latLng.latitude, latLng.longitude);
      final result = await _places.searchNearbyWithRadius(location, 2500 ,type:"lodging",language: defaultLocale);
        if (result.status == "OK") {
            return result.results;
        }
        else{throw result.errorMessage;}
    }
    catch(Error){
      throw PlacesNotFoundException(Error.toString());
    }
  }

  fetchPlacesFromDataBase(userName) {

  }
/*If you are using this app u should create your own asset file with text instance of ApiKey for GooglePlaces
  more info on https://developers.amadeus.com/self-service/apis-docs/guides/authorization-262 */
Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/sensitive.txt');
}
}
class PlacesNotFoundException implements Exception {
  final String error;
  PlacesNotFoundException(this.error);
}