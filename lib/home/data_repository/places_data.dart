import 'dart:io';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;

class HomeDataRepository {
  Future<List<PlacesDetail>> fetchPlacesFromNetwork(LatLng latLng) async {
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final location = Location(lat:latLng.latitude, lng:latLng.longitude);
      final result = await _places.searchNearbyWithRadius(location, 2500 ,type:"lodging",language: defaultLocale);
        if (result.status == "OK"&&result.results.isNotEmpty) {
          var j = 0;
          List<PlacesDetail> list= new List<PlacesDetail>(result.results.length);
          list.forEach((element) {
            var k = 0;
            List<ImageProvider> photos;
            if (result.results[j].photos!=null){
              photos= new List<ImageProvider>(result.results[j].photos.length);
            photos.forEach((element) {
              photos[k]=Image.network(buildPhotoURL(result.results[j].photos[k].photoReference, kGoogleApiKey)).image;
            k++;});}
            list[j]= PlacesDetail(
              icon:result.results[j].icon,
              name:result.results[j].name,
              openingHours:result.results[j].openingHours==null?null:result.results[j].openingHours.openNow,
              photos:photos,
              placeId:result.results[j].placeId,
              priceLevel:result.results[j].priceLevel.toString(),
              rating:result.results[j].rating,
              types:result.results[j].types,
              vicinity:result.results[j].vicinity,
              formattedAddress:result.results[j].formattedAddress,
              permanentlyClosed:result.results[j].permanentlyClosed,
              reference:result.results[j].reference,
            );j++;});
            return list;
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

  String buildPhotoURL(String photoReference, String googleApiKey) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=700&photoreference=$photoReference&key=$googleApiKey";
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