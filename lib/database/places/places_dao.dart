import 'dart:async';
import 'package:find_hotel/database/database.dart';
import 'package:find_hotel/database/places/places_db_model.dart';
class PlacesDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPlaces(PlacesDbDetail placesDbDetail) async {
    final db = await dbProvider.database;
    var result = db.insert(placesTABLE, placesDbDetail.toDatabaseJson());
    return result;
  }

  Future<List<PlacesDbDetail>> getPlaces({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(placesTABLE);
    } else {
      result = await db.query(placesTABLE, columns: columns);
    }

    List<PlacesDbDetail> places = result.isNotEmpty
        ? result.map((item) => PlacesDbDetail.fromDatabaseJson(item)).toList()
        : [];
    return places;
  }

  Future deleteAllPlaces() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      placesTABLE,
    );

    return result;
  }
}