import 'package:find_hotel/database/places/places_dao.dart';
import 'package:find_hotel/database/places/places_db_model.dart';

class PlacesRepository {
  final placesDao = PlacesDao();

  Future<List<PlacesDbDetail>> getAllPlaces({String  query}) => placesDao.getAllPlaces(query: query);

  Future<List<PlacesDbDetail>> getFavoritePlaces({String  query}) => placesDao.getUserFavoritePlaces();

  Future<List<PlacesDbDetail>> getNearestPlaces({String  query}) => placesDao.getUserNearestPlaces();

  Future<List<PlacesDbDetail>> getRecentlyViewedPlaces({String  query}) => placesDao.getUserRecentlyViewedPlaces();

  Future insertPlace(PlacesDbDetail repo) => placesDao.createPlaces(repo);

  Future updatePlace(PlacesDbDetail place) => placesDao.updatePlace(place);

  Future deletePlace(String placeId) => placesDao.deletePlace(placeId);

  Future deleteAllPlaces() => placesDao.deleteAllPlaces();

  Future getPlace(String placeId) => placesDao.getPlace(placeId);

  Future checkIfExist(String placeId) => placesDao.checkIfExist(placeId);
}