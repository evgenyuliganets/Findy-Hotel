import 'dart:io';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;

class HomeDataRepository {
  Future<PlacesDetail> fetchDetailedPlaceFromNetwork(String placeId) async {
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final result = await _places.getDetailsByPlaceId(placeId,language: defaultLocale);
      if (result.status == "OK"&&result.result!=null) {
          var k = 0;
          List<ImageProvider> photos;
          if (result.result.photos!=null){
            photos= new List<ImageProvider>(result.result.photos.length);
            photos.forEach((element) {
              photos[k]=Image.network(buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey)).image;
              k++;});}
          final list= PlacesDetail(
            icon:result.result.icon,
            name:result.result.name,
            openNow:result.result.openingHours==null?null:result.result.openingHours.openNow,
            photos:photos,
            placeId:result.result.placeId,
            priceLevel:result.result.priceLevel.toString(),
            rating:result.result.rating,
            types:result.result.types,
            vicinity:result.result.vicinity,
            formattedAddress:result.result.formattedAddress,
            weekDay:result.result.openingHours==null?null:result.result.openingHours.weekdayText,
            reference:result.result.reference,
          );
        return list;
      }
      else{result.errorMessage != null
          ? throw result.errorMessage
          : result.status == 'ZERO_RESULTS'
          ? throw PlacesNotFoundException("No results found")
          : throw 'UnknownError';}
    }
    catch(Error){
      if (Error is PlacesNotFoundException) {
        print(Error.error + 'MY');
        PlacesNotFoundException placesNotFoundException = PlacesNotFoundException(
            Error.error);
        placesNotFoundException.returnError(Error.error);
        throw placesNotFoundException;
      }
      else throw Error;
    }
  }


  Future<List<PlacesDetail>> fetchPlacesFromNetwork(LatLng latLng) async {
    try{
      String defaultLocale = Platform.localeName;
      print(defaultLocale.toString());
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final location = Location(lat:latLng.latitude, lng:latLng.longitude);
      final result = await _places.searchNearbyWithRadius(location, 50000 ,type:"lodging",language: defaultLocale,keyword: 'spa');
      print(result.toJson().toString());
        if (result.status == "OK"&&result.hasNoResults!=true&&result.isNotFound!=true) {
          print(result.results.first.toJson());
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
              openNow:result.results[j].openingHours==null?null:result.results[j].openingHours.openNow,
              photos:photos,
              placeId:result.results[j].placeId,
              priceLevel:result.results[j].priceLevel.toString(),
              rating:result.results[j].rating,
              types:result.results[j].types,
              vicinity:result.results[j].vicinity,
              formattedAddress:result.results[j].formattedAddress,
              reference:result.results[j].reference,
            );j++;});
          print (list.toString());
            return list;
        } else {
        result.errorMessage != null
            ? throw result.errorMessage
            : result.status == 'ZERO_RESULTS'
                ? throw PlacesNotFoundException("No results found")
                : throw 'UnknownError';
      }
    } catch(Exception){
      if (Exception is PlacesNotFoundException) {
        print(Exception.error + 'MY');
        PlacesNotFoundException placesNotFoundException = PlacesNotFoundException(
            Exception.error);
        placesNotFoundException.returnError(Exception.error);
        throw placesNotFoundException;
      }
      else throw Exception;
    }
   }

  Future<LatLng> getUserLocation() async {
    var currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final center = LatLng(currentLocation.latitude, currentLocation.longitude);
      print(center.toString());
      return center;
    } catch (Exception) {
      print (Exception.toString());
      var permissionStatus =await location.hasPermission();
      print (permissionStatus.toString());
      if(permissionStatus== LocationManager.PermissionStatus.granted){
      currentLocation = await location.getLocation();
      return LatLng(currentLocation.latitude, currentLocation.longitude);
      }
      else{
      currentLocation = null;
      return null;}
    }
  }

  fetchPlacesFromDataBase(userName) {

  }
  fetchPlaceDetailFromDataBase(placeId) {

  }
  String buildPhotoURL(String photoReference, String googleApiKey) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=$photoReference&key=$googleApiKey";
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

  void returnError(error) {
    return error;
  }
   get getError{
      return error;
  }
}