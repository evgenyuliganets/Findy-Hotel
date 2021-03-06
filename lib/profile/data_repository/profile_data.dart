import 'dart:convert';
import 'package:find_hotel/database/photos/photos_db_model.dart';
import 'package:find_hotel/database/photos/photos_repository.dart';
import 'package:find_hotel/database/places/places_db_model.dart';
import 'package:find_hotel/database/places/places_repository.dart';
import 'package:find_hotel/home/model/places_detail_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ProfileRepository {
  final BuildContext context;
  var _placesRepository = PlacesRepository();
  var _photosRepository = PhotosRepository();

  ProfileRepository(this.context);

  List<String> typesFromJson(String str) => List<String>.from(json.decode(str).map((x) => x));


  Future <List<PlacesDetail>> fetchFavoritePlacesFromDataBase() async {
    try{
      List<PlacesDbDetail> placesDatabase = await _placesRepository.getFavoritePlaces();
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
            types: typesFromJson(placesDatabase[j].types),
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

  Future <List<PlacesDetail>> fetchRecentlyViewedPlacesFromDataBase() async {
    try{
      List<PlacesDbDetail> placesDatabase = await _placesRepository.getRecentlyViewedPlaces();
      List<List<PhotosDbDetail>> photoDatabase= List<List<PhotosDbDetail>>(placesDatabase.length);
      List<List<ImageProvider>> listImages=List<List<ImageProvider>>(placesDatabase.length);

      print(placesDatabase);
      for(int i =0;i<photoDatabase.length;i++){
        photoDatabase[i] = await _photosRepository.getSelectedPhotos(placesDatabase[i].placeId);
        listImages[i]=List<ImageProvider>(photoDatabase[i].length);
        for(int j =0;j<photoDatabase[i].length;j++){
          listImages[i][j]=Image.memory(photoDatabase[i][j].photo).image;
        }
      }

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
            types: typesFromJson(placesDatabase[j].types),
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

  Future <List<PlacesDetail>> fetchNearestPlacesFromDataBase() async {
    try{
      List<PlacesDbDetail> placesDatabase = await _placesRepository.getNearestPlaces();
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
            types: typesFromJson(placesDatabase[j].types),
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