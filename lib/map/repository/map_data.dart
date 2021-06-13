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

class MapRepository {
  var _placesRepository = PlacesRepository();
  var _photosRepository = PhotosRepository();
  Future<PlacesDetail> fetchDetailedMapPlaceFromNetwork(String placeId) async {
    var weekday = DateTime.now();
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final result = await _places.getDetailsByPlaceId(placeId,language: defaultLocale).timeout(Duration(seconds: 5));
      if (result.status == "OK" && !result.hasNoResults) {
        var k = 0;
        List<ImageProvider> photos= List<ImageProvider>(result.result.photos.length);
        List<String> photosUrls= List<String>(result.result.photos.length);
        List<String> photosReferences= List<String>(result.result.photos.length);
        if (result.result.photos.isNotEmpty){
          photos.forEach((element) {
            photosUrls[k]=buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey);
            photosReferences[k]=result.result.photos[k].photoReference;
            photos[k]=Image.network(buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey)).image;
            k++;});}
        final list= PlacesDetail(
            latitude: result.result.geometry.location.lat,
            longitude: result.result.geometry.location.lng,
            icon:result.result.icon,
            name:result.result.name,
            openNow:result.result.openingHours==null?"null":result.result.openingHours.openNow.toString(),
            photos:photos,
            placeId:result.result.placeId,
            priceLevel:result.result.priceLevel.toString(),
            rating:result.result.rating,
            types:result.result.types,
            vicinity:result.result.vicinity,
            formattedAddress:result.result.formattedAddress,
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
        addPlaceToDatabase(list,photosUrls, isRecentlyViewed: true);
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
  Future<void> addPlaceToDatabase(PlacesDetail place,List<String> photosUrls,{bool isNearest, bool isRecentlyViewed, bool isFavorite}) async {
    bool ifExist;
    await _placesRepository.checkIfExist(place.placeId).then((value) =>
    ifExist = value);
    if (ifExist == true) {
      _placesRepository.updatePlace(await parsePlaceForDatabase(
          place, photosUrls,
          isNearest: isNearest,
          isRecentlyViewed: isRecentlyViewed,
          isFavorite: isFavorite));
    }
    else
      _placesRepository.insertPlace(await parsePlaceForDatabase(
          place, photosUrls,
          isNearest: isNearest,
          isRecentlyViewed: isRecentlyViewed,
          isFavorite: isFavorite));
  }

  Future<PlacesDbDetail> parsePlaceForDatabase(
      PlacesDetail place, List<String> photosUrls,
      {bool isNearest, bool isRecentlyViewed, bool isFavorite}) async {

    await _photosRepository.deleteSelectedPhotos(place.placeId);
    Future.wait(photosUrls
        .map((e) => NetworkAssetBundle(Uri.parse("")).load(e).then((value) {
      var responses = List.empty(growable: true);
      responses.add(value);
      print('$e PHOTO');
      _photosRepository.insertPhoto(PhotosDbDetail(
        placeId: place.placeId,
        photo: value.buffer.asUint8List(),
      ));
    })));

    return PlacesDbDetail(
      icon:place.icon,
      isNearest: isNearest.toString(),
      isRecentlyViewed: isRecentlyViewed.toString(),
      isFavorite: isFavorite.toString(),
      name:place.name,
      openNow:place.openNow,
      latitude: place.latitude,
      longitude: place.longitude,
      placeId:place.placeId,
      priceLevel:place.priceLevel,
      rating:place.rating,
      types: jsonEncode(place.types),
      vicinity:place.vicinity,
      formattedAddress:place.formattedAddress,
      openingHours: place.openingHours,
      website:place.website,
      utcOffset:place.utcOffset,
      formattedPhoneNumber:place.formattedPhoneNumber,
      internationalPhoneNumber:place.internationalPhoneNumber,
    );
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
                .searchNearbyWithRadius(
                location, searchFilterModel.radius,
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
            'Location permission is not granted, please grant permission to see places near you');
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
        throw PlacesMapNotFoundException('Places in Database was not found');
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
          throw PlacesMapNotFoundException('Places in Database was not found');
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

  Future <PlacesDetail> fetchMapPlaceDetailFromDataBase(placeId) async {
    try{
      PlacesDbDetail placeDatabase=  await _placesRepository.getPlace(placeId);
      List<PhotosDbDetail> photoDatabase=  await _photosRepository.getSelectedPhotos(placeId);
      List<ImageProvider> listImages=List(photoDatabase.length);
      var j=0;
      photoDatabase.forEach((element) {listImages[j]=Image.memory(element.photo).image; j++;});
      if (placeDatabase==null) {
        throw PlacesMapNotFoundException('This place was not found in Database');
      } else {
        final place = PlacesDetail(
          icon:placeDatabase.icon,
          name:placeDatabase.name,
          openNow:placeDatabase.openNow==null?"null":placeDatabase.openNow.toString(),
          latitude: placeDatabase.latitude,
          longitude: placeDatabase.longitude,
          photos:listImages,
          placeId:placeDatabase.placeId,
          priceLevel:placeDatabase.priceLevel.toString(),
          rating:placeDatabase.rating,
          types:typesFromJson(placeDatabase.types),
          vicinity:placeDatabase.vicinity,
          formattedAddress:placeDatabase.formattedAddress,
          utcOffset:placeDatabase.utcOffset,
          formattedPhoneNumber:placeDatabase.formattedPhoneNumber,
          openingHours: placeDatabase.openingHours ,
        );
        return place;
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