import 'dart:async';
import 'dart:io';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;

class MapRepository {
  Future<PlacesDetail> fetchDetailedMapPlaceFromNetwork(String placeId) async {
    var weekday = DateTime.now();
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final result = await _places.getDetailsByPlaceId(placeId,language: defaultLocale).timeout(Duration(seconds: 5));
      if (result.status == "OK" && !result.hasNoResults) {
        var k = 0;
        List<ImageProvider> photos;
        if (result.result.photos.isNotEmpty){
          photos= new List<ImageProvider>(result.result.photos.length);
          photos.forEach((element) {
            photos[k]=Image.network(buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey)).image;
            k++;});}
        final list= PlacesDetail(
            latitude: result.result.geometry.location.lat,
            longitude: result.result.geometry.location.lng,
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
            utcOffset:result.result.utcOffset,
            formattedPhoneNumber: result.result.formattedPhoneNumber,
            openingHours: result.result.openingHours != null
                ? result.result.openingHours.weekdayText.isNotEmpty
                ? result.result.openingHours.weekdayText.first ==
                'Monday: Open 24 hours'
                ? 'Open 24 hours'
                : result.result.openingHours != null
                ? result.result.openingHours.periods.isNotEmpty
                ? result.result.openingHours.periods.first
                .close !=
                null
                ? result.result.openingHours.openNow
                ? result.result.openingHours
                .periods[weekday.weekday].close.time
                : result.result.openingHours
                .periods[weekday.weekday].open.time
                : null
                : null
                : null
                : null
                : null);
        print(result.result.toJson().toString());
        return list;
      }
      else{result.errorMessage != null
          ? throw result.errorMessage
          : result.status == 'ZERO_RESULTS'
          ? throw PlacesMapNotFoundException("Place not found, try again later")
          : throw 'Unknown Error';}
    }on TimeoutException {
      throw PlacesMapNotFoundException(
          'Timeout was reached, try reload later or check connection');
    } catch (Exception) {
      if (Exception is PlacesMapNotFoundException) {
        print(Exception.error + 'MY');
        PlacesMapNotFoundException placesNotFoundException =
        PlacesMapNotFoundException(Exception.error);
        throw placesNotFoundException;
      } else
        throw Exception;
    }
  }


  Future<List<PlacesDetail>> fetchMapPlacesFromNetwork(SearchFilterModel searchFilterModel,{String textFieldText,bool mainSearchMode,LatLng latLng}) async {
    try {
      var weekday = DateTime.now();
      String defaultLocale = Platform.localeName;
      print(defaultLocale.toString());
      var kGoogleApiKey = await loadAsset();
      PlacesSearchResponse result;
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
      );
      if (searchFilterModel.rankBy) {
        final location =
        Location(lat: latLng.latitude, lng: latLng.longitude);
        result = await _places
            .searchNearbyWithRankBy(location,
            'distance',
            type: "lodging",
            minprice: getPriceLevel(searchFilterModel.minprice),
            maxprice: getPriceLevel(searchFilterModel.maxprice),
            language: defaultLocale,
            keyword: searchFilterModel.keyword)
            .timeout(
          Duration(seconds: 5),
        );
      } else {
        print("mainSearchMode " + mainSearchMode.toString());
        if (mainSearchMode != null) {
          if (mainSearchMode == true) {
            print('Search by text');
            result = await _places
                .searchByText(
              textFieldText,
              minprice: getPriceLevel(searchFilterModel.minprice),
              maxprice: getPriceLevel(searchFilterModel.maxprice),
              radius: searchFilterModel.radius,
              type: "lodging",
              language: defaultLocale,
            )
                .timeout(
              Duration(seconds: 5),
            );
            print(_places.buildTextSearchUrl(
              query: textFieldText,
              type: "lodging",
              language: defaultLocale,
            ));
          } else {
            final location =
            Location(lat: latLng.latitude, lng: latLng.longitude);
            print('Search by place');
            result = await _places
                .searchNearbyWithRadius(location, searchFilterModel.radius,
                type: "lodging",
                minprice: getPriceLevel(searchFilterModel.minprice),
                maxprice: getPriceLevel(searchFilterModel.maxprice),
                language: defaultLocale,
                keyword: searchFilterModel.keyword)
                .timeout(
              Duration(seconds: 5),
            );
          }
        } else {
          final location =
          Location(lat: latLng.latitude, lng: latLng.longitude);
          print('Search by place');
          result = await _places
              .searchNearbyWithRadius(location, searchFilterModel.radius,
              type: "lodging",
              language: defaultLocale,
              keyword: searchFilterModel.keyword)
              .timeout(
            Duration(seconds: 5),
          );
        }
      }
      print('RESULT '+result.toJson().toString());
      if (result.status == "OK" &&
          result.hasNoResults != true &&
          result.isNotFound != true) {
        print(result.results.first.toJson());
        var j = 0;
        List<PlacesDetail> list = new List<PlacesDetail>(result.results.length);
        list.forEach((element) {
          var k = 0;
          List<ImageProvider> photos;
          if (result.results[j].photos != null) {
            photos = new List<ImageProvider>(result.results[j].photos.length);
            photos.forEach((element) {
              photos[k] = Image.network(buildPhotoURL(
                  result.results[j].photos[k].photoReference,
                  kGoogleApiKey))
                  .image;
              k++;
            });
          }
          list[j] = PlacesDetail(
            icon: result.results[j].icon,
            name: result.results[j].name,
            latitude: result.results[j].geometry.location.lat,
            longitude: result.results[j].geometry.location.lng,
            openNow: result.results[j].openingHours == null
                ? null
                : result.results[j].openingHours.openNow,
            photos: photos,
            placeId: result.results[j].placeId,
            priceLevel: result.results[j].priceLevel.toString(),
            rating: result.results[j].rating,
            types: result.results[j].types,
            vicinity: result.results[j].vicinity,
            formattedAddress: result.results[j].formattedAddress,
          );
          j++;
        });
        return list;
      } else {
        result.errorMessage != null
            ? throw result.errorMessage
            : result.status == 'ZERO_RESULTS'
            ? throw PlacesMapNotFoundException(
            "No results found, try change filters")
            : throw 'UnknownError';
      }
    } on TimeoutException {
      throw PlacesMapNotFoundException(
          'Timeout was reached, try change filters or check connection');
    } catch (Exception) {
      if (Exception is PlacesMapNotFoundException) {
        print(Exception.error + 'MY');
        PlacesMapNotFoundException placesNotFoundException =
        PlacesMapNotFoundException(Exception.error);
        throw placesNotFoundException;
      } else
        throw Exception;
    }
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation;
    final location = LocationManager.Location();
    try {
      print("seconds - ${DateTime.now().second}    milisec - ${DateTime.now().microsecond}");
      currentLocation = await location.getLocation();
      print("seconds - ${DateTime.now().second}    milisec - ${DateTime.now().microsecond}");
      final center = LatLng(currentLocation.latitude, currentLocation.longitude);
      print(center.toString());
      return center;
    } catch (Exception) {
      print (Exception.toString());
      print("seconds - ${DateTime.now().second}    milisec - ${DateTime.now().microsecond}");
      var permissionStatus =await location.hasPermission();
      print (permissionStatus.toString());
      if(permissionStatus== LocationManager.PermissionStatus.granted){
        print("seconds - ${DateTime.now().second}    milisec - ${DateTime.now().microsecond}");
        currentLocation = await location.getLocation();
        return LatLng(currentLocation.latitude, currentLocation.longitude);
      }
      else{
        currentLocation = null;
        return null;}
    }
  }

  fetchPlacesFromDataBase() {

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
  PriceLevel getPriceLevel(int inputPrice) {
    switch (inputPrice){
      case 0:
        return PriceLevel.free;
        break;
      case 1:
        return PriceLevel.inexpensive;
        break;
      case 2:
        return PriceLevel.moderate;
        break;
      case 3:
        return PriceLevel.expensive;
        break;
      case 4:
        return PriceLevel.veryExpensive;
        break;
      default:
        return null;
        break;
    }
  }
}
class PlacesMapNotFoundException implements Exception {
  final String error;

  PlacesMapNotFoundException(this.error);

}