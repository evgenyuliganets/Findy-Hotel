import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:find_hotel/database/photos/photos_db_model.dart';
import 'package:find_hotel/database/photos/photos_repository.dart';
import 'package:find_hotel/database/places/places_db_model.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:find_hotel/home/model/search_filters_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapRepository {
  final BuildContext context;
  var _placesRepository = PlacesRepository();
  var _photosRepository = PhotosRepository();
  MapRepository(this.context);


  Future<List<PlacesDetail>> fetchMapPlacesFromNetwork(SearchFilterModel searchFilterModel,{String textFieldText,bool mainSearchMode,LatLng latLng}) async {
    try {
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
            minprice: getPriceLevel(searchFilterModel.minPrice),
            maxprice: getPriceLevel(searchFilterModel.maxPrice),
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
              minprice: getPriceLevel(searchFilterModel.minPrice),
              maxprice: getPriceLevel(searchFilterModel.maxPrice),
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
                .searchNearbyWithRadius(
                location, searchFilterModel.radius,
                type: "lodging",
                minprice: getPriceLevel(searchFilterModel.minPrice),
                maxprice: getPriceLevel(searchFilterModel.maxPrice),
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
                ? "null"
                : result.results[j].openingHours.openNow.toString(),
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
            AppLocalizations.of(context).noResultsErr)
            : throw AppLocalizations.of(context).unknownError;
      }
    } on TimeoutException {
      throw PlacesMapNotFoundException(
          AppLocalizations.of(context).timeoutRepoError);
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
        throw PlacesMapNotFoundException(
            AppLocalizations.of(context).locPermissionErr);
      }
    }
  }

  Future <List<PlacesDetail>> fetchAllMapPlacesFromDataBase() async {
    try{
      List<PlacesDbDetail> placesDatabase = await _placesRepository.getAllPlaces();
      List<List<PhotosDbDetail>> photoDatabase= List<List<PhotosDbDetail>>(placesDatabase.length);
      List<List<ImageProvider>> listImages=List<List<ImageProvider>>(placesDatabase.length);


      for(int i =0;i<photoDatabase.length;i++){
        photoDatabase[i] = await _photosRepository.getSelectedPhotos(placesDatabase[i].placeId);
        listImages[i]=List<ImageProvider>(photoDatabase[i].length);
        for(int j =0;j<photoDatabase[i].length;j++){
          listImages[i][j]=Image.memory(photoDatabase[i][j].photo).image;
        }
      }

      if (placesDatabase.isEmpty) {
        throw PlacesMapNotFoundException(AppLocalizations.of(context).placesDatabaseErr);
      } else {
        var j = 0;
        List<PlacesDetail> list= new List<PlacesDetail>(placesDatabase.length);
        list.forEach((element) {
          list[j]= PlacesDetail(
            icon:placesDatabase[j].icon,
            name:placesDatabase[j].name,
            openNow:placesDatabase[j].openNow==null?"null":placesDatabase[j].openNow.toString(),
            latitude: placesDatabase[j].latitude,
            longitude: placesDatabase[j].longitude,
            photos:listImages[j],
            placeId:placesDatabase[j].placeId,
            priceLevel:placesDatabase[j].priceLevel.toString(),
            rating:placesDatabase[j].rating,
            types: typesFromJson(placesDatabase[j].types),
            vicinity:placesDatabase[j].vicinity,
            formattedAddress:placesDatabase[j].formattedAddress,
            utcOffset:placesDatabase[j].utcOffset,
            formattedPhoneNumber:placesDatabase[j].formattedPhoneNumber,
            openingHours: placesDatabase[j].openingHours ,
          );
          j++;
        });
        if (list.isEmpty) {
          throw PlacesMapNotFoundException(AppLocalizations.of(context).placesDatabaseErr);
        }else{
        return list;}
      }
    } catch (Exception) {
      if (Exception is PlacesMapNotFoundException) {
        print(Exception.error + 'MY');
        PlacesMapNotFoundException placesNotFoundException =
        PlacesMapNotFoundException(Exception.error);
        throw placesNotFoundException;
      } else
        print(Exception.toString() + 'MY');
      throw PlacesMapNotFoundException(Exception.toString());
    }
  }
  List<String> typesFromJson(String str) => List<String>.from(json.decode(str).map((x) => x));

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