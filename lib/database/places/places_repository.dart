import 'package:find_hotel/database/places/places_dao.dart';
import 'package:find_hotel/database/places/places_db_model.dart';

class PlacesRepository {
  final placesDao = PlacesDao();

  Future<List<PlacesDbDetail>> getAllUser({String  query}) => placesDao.getPlaces(query: query);

  Future insertUser(PlacesDbDetail user) => placesDao.createPlaces(user);

  Future deleteAllUsers() => placesDao.deleteAllPlaces();
}