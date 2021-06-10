import 'dart:async';
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

class HomeDataRepository {
  var _placesRepository = PlacesRepository();
  var _photosRepository = PhotosRepository();

  Future<PlacesDetail> fetchDetailedPlaceFromNetwork(String placeId) async {
    var weekday = DateTime.now();
    try{
      String defaultLocale = Platform.localeName;
      var kGoogleApiKey = await loadAsset();
      GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey,);
      final result = await _places.getDetailsByPlaceId(placeId,language: defaultLocale).timeout(Duration(seconds: 5));
      if (result.status == "OK" && !result.hasNoResults) {
          var k = 0;
          List<ImageProvider> photos;
          List<String> photosUrls;
          List<String> photosReferences;
          if (result.result.photos.isNotEmpty){
            photosReferences = new List<String>(result.result.photos.length);
            photosUrls = new List<String>(result.result.photos.length);
            photos= new List<ImageProvider>(result.result.photos.length);
            photos.forEach((element) {
              photosUrls[k]=buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey);
              photosReferences[k]=result.result.photos[k].photoReference;
              photos[k]=Image.network(buildPhotoURL(result.result.photos[k].photoReference, kGoogleApiKey)).image;
              k++;});}
          final list= PlacesDetail(
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
          addPlaceToDatabase(list,photosUrls,photosReferences);
          print(result.result.toJson().toString());
        return list;
      }
      else{result.errorMessage != null
          ? throw result.errorMessage
          : result.status == 'ZERO_RESULTS'
          ? throw PlacesNotFoundException("Place not found, try again later")
          : throw 'Unknown Error';}
    }on TimeoutException {
      throw PlacesNotFoundException(
          'Timeout was reached, try reload later or check connection');
    } catch (Exception) {
      if (Exception is PlacesNotFoundException) {
        print(Exception.error + 'MY');
        PlacesNotFoundException placesNotFoundException =
        PlacesNotFoundException(Exception.error);
        throw placesNotFoundException;
      } else
        throw Exception;
    }
  }


  addPlaceToDatabase(PlacesDetail place,List<String> photosUrls,List<String> photosReferences) async {
    bool ifExist;
    await _placesRepository.checkIfExist(place.placeId).then((value) =>
    ifExist = value);
    if (ifExist == true) {
      _placesRepository.updatePlace(await parseRepoFromDatabase(place,photosUrls,photosReferences));
    }
    else
      _placesRepository.insertPlace(await parseRepoFromDatabase(place,photosUrls,photosReferences));
  }

  Future<PlacesDbDetail> parseRepoFromDatabase(PlacesDetail place, List<String> photosUrls,List<String> photosReferences) async {
    var responses = List(photosUrls.length);
    var i=0;
    for(var element in photosUrls) {
      print(photosUrls[i].toString()+' PHOTOS URLS');
      await NetworkAssetBundle(Uri.parse("")).load(element).then((value) => responses[i]=value);
      i++;
    }
    bool ifExist;
    var j=0;
    List<Uint8List> listPhotosUint= List<Uint8List>(responses.length);
    for(var element in responses) {
      listPhotosUint[j]=(element).buffer.asUint8List();
      await _photosRepository.checkIfExist(place.placeId, photosReferences[j]).then((value) =>
      ifExist = value);
      print(ifExist.toString()+' ifExist');
      if (ifExist == true) {
        _photosRepository.updatePhoto(PhotosDbDetail(
          placeId: place.placeId,
          photo: listPhotosUint[j],
          photosReference: photosReferences[j],
        ));
      }
      else{
        _photosRepository.insertPhoto(PhotosDbDetail(
          placeId: place.placeId,
          photo: listPhotosUint[j],
          photosReference: photosReferences[j],
        ));}
    j++;
    }
    return PlacesDbDetail(
      icon:place.icon,
      name:place.name,
      openNow:place.openNow,
      latitude: place.latitude,
      longitude: place.longitude,
      placeId:place.placeId,
      priceLevel:place.priceLevel,
      rating:place.rating,
      vicinity:place.vicinity,
      formattedAddress:place.formattedAddress,
      openingHours: place.openingHours,
      website:place.website,
      utcOffset:place.utcOffset,
      formattedPhoneNumber:place.formattedPhoneNumber,
      internationalPhoneNumber:place.internationalPhoneNumber,
    );
  }


  Future<List<PlacesDetail>> fetchPlacesFromNetwork(SearchFilterModel searchFilterModel,{String textFieldText,bool mainSearchMode,LatLng latLng}) async {
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
                ? throw PlacesNotFoundException(
                    "No results found, try change filters")
                : throw 'UnknownError';
      }
    } on TimeoutException {
      throw PlacesNotFoundException(
          'Timeout was reached, try change filters or check connection');
    } catch (Exception) {
      if (Exception is PlacesNotFoundException) {
        print(Exception.error + 'MY');
        PlacesNotFoundException placesNotFoundException =
            PlacesNotFoundException(Exception.error);
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

  Future <List<PlacesDetail>> fetchAllPlacesFromDataBase() async {

        List<PlacesDbDetail> placesDatabase = await _placesRepository.getAllPlaces();
        List<List<PhotosDbDetail>> photoDatabase= List<List<PhotosDbDetail>>(placesDatabase.length);
        List<List<ImageProvider>> listImages=List<List<ImageProvider>>(photoDatabase.length);

        var j=0;
        placesDatabase.forEach((element) async {
          photoDatabase[j]= await _photosRepository.getSelectedPhotos(element.placeId);j++;});
        print(placesDatabase);
        print(listImages);

        for(int i =0;i<photoDatabase.length;i++){
          photoDatabase[i] = await _photosRepository.getSelectedPhotos(placesDatabase[i].placeId);
          print(placesDatabase.toString());
          for(int j =0;j<photoDatabase[i].length;j++){
            listImages[i][j]=Image.memory(photoDatabase[i][j].photo).image;
            print(listImages.toString());
          }
        }
        print(placesDatabase);
        print(listImages);

        if (placesDatabase.isEmpty) {
          throw PlacesNotFoundException('Places in Database was not found');
        } else {
          var j = 0;
          List<PlacesDetail> list= new List<PlacesDetail>(placesDatabase.length);
          list.forEach((element) {
            list[j]= PlacesDetail(
              icon:placesDatabase[j].icon,
              name:placesDatabase[j].name,
              openNow:placesDatabase[j].openNow==null?"null":placesDatabase[j].openNow.toString(),
              photos:listImages[j],
              placeId:placesDatabase[j].placeId,
              priceLevel:placesDatabase[j].priceLevel.toString(),
              rating:placesDatabase[j].rating,
              types:null,
              vicinity:placesDatabase[j].vicinity,
              formattedAddress:placesDatabase[j].formattedAddress,
              utcOffset:placesDatabase[j].utcOffset,
              formattedPhoneNumber:placesDatabase[j].formattedPhoneNumber,
              openingHours: placesDatabase[j].openingHours ,
            );
            j++;
          });
          return list;
        }


  }
  Future <PlacesDetail> fetchPlaceDetailFromDataBase(placeId) async {
      try{
        PlacesDbDetail placeDatabase=  await _placesRepository.getPlace(placeId);
        List<PhotosDbDetail> photoDatabase=  await _photosRepository.getSelectedPhotos(placeId);
        List<ImageProvider> listImages=List(photoDatabase.length);
        /*
        List<String> listTypes=List(photoDatabase.length);
        var i=0;
        photoDatabase.forEach((element) {listTypes[j]=element.type; i++;});*/
        var j=0;
        photoDatabase.forEach((element) {listImages[j]=Image.memory(element.photo).image; j++;});
        if (placeDatabase==null) {
          print('No places found in Database');
          throw PlacesNotFoundException('No places found in Database');
        } else {
          final place = PlacesDetail(
              icon:placeDatabase.icon,
              name:placeDatabase.name,
              openNow:placeDatabase.openNow==null?"null":placeDatabase.openNow.toString(),
              photos:listImages,
              placeId:placeDatabase.placeId,
              priceLevel:placeDatabase.priceLevel.toString(),
              rating:placeDatabase.rating,
              types:null,
              vicinity:placeDatabase.vicinity,
              formattedAddress:placeDatabase.formattedAddress,
              utcOffset:placeDatabase.utcOffset,
              formattedPhoneNumber:placeDatabase.formattedPhoneNumber,
              openingHours: placeDatabase.openingHours ,
          );
          return place;
        }
      } catch (Exception) {
        if (Exception is PlacesNotFoundException) {
          print(Exception.error + 'MY');
          PlacesNotFoundException placesNotFoundException =
          PlacesNotFoundException(Exception.error);
          throw placesNotFoundException;
        } else
          print(Exception.toString() + 'MY');
          throw PlacesNotFoundException(Exception.toString());
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

class PlacesNotFoundException implements Exception {
  final String error;

  PlacesNotFoundException(this.error);

   get getError{
      return error;
  }
}